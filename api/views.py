from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import *
from .models import *
from django.db import transaction
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters
from rest_framework.decorators import action
from rest_framework import mixins
from rest_framework.viewsets import GenericViewSet
from django.db.models import Sum, F, Q
from rest_framework.permissions import AllowAny
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import smart_bytes
from api.permissions import *
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from django.contrib.auth.tokens import PasswordResetTokenGenerator


class TokenPairViewset(TokenObtainPairView):
    serializer_class = TokenPairSerializer

class UserViewset(viewsets.ReadOnlyModelViewSet):
    authentication_classes = (SessionAuthentication, JWTAuthentication)
    permission_classes = [IsAuthenticated]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        ser = TokenPairSerializer(data=request.data, context={'request': request})
        ser.is_valid(raise_exception=True)
        return Response(ser.validated_data)

    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='request-reset',serializer_class=PasswordResetRequestSerializer)
    def request_reset(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            return Response({"status": "Aucun utilisateur trouvé avec cet email."},400)

        uidb64 = urlsafe_base64_encode(smart_bytes(user.pk))
        token = PasswordResetTokenGenerator().make_token(user)
        reset_url = f"http://localhost:8000/user/confirm-reset/{uidb64}/{token}/"

        send_mail(
            subject="Réinitialisation de votre mot de passe",
            message=f"Pour réinitialiser votre mot de passe, cliquez sur ce lien : {reset_url}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )

        return Response({"message": "Lien de réinitialisation envoyé."})

    @action(detail=False, methods=['get','post'], permission_classes=[AllowAny], url_path='confirm-reset/(?P<uidb64>[^/]+)/(?P<token>[^/]+)',serializer_class=PasswordResetConfirmSerializer)
    def confirm_reset(self, request, uidb64=None, token=None):
        if request.method == 'GET':
            return Response(200)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return Response({"status": "Lien invalide."},400)

        if not PasswordResetTokenGenerator().check_token(user, token):
            return Response({"status": "Le token est invalide ou a expiré. Veuillez demander un nouveau lien."},400)

        user.set_password(serializer.validated_data['new_password'])
        user.save()

        return Response({"status": "Mot de passe réinitialisé avec succès."})
    

class MultiplicatorViewset(viewsets.ModelViewSet):
    queryset = Multiplicator.objects.all()
    serializer_class = MultiplicatorSerializer
    authentication_classes = (SessionAuthentication, JWTAuthentication)
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend]
    search_fields = ['user__username', 'province', 'commune', 'colline']
    filterset_fields = ['is_validated', 'type_multiplicator', 'types', 'user__username', 'province', 'commune', 'colline']


    def get_permissions(self):
        if self.action == 'create':
            return [IsAnonymous()]
        return [AllowAny()]

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user_data = data.pop('user')
        groups = user_data.pop('groups', [])

        existing_user = User.objects.filter(username=user_data['username']).first()

        if existing_user:
            existing_multiplicator = Multiplicator.objects.filter(user=existing_user, is_validated=False).first()
            if existing_multiplicator:
                existing_multiplicator.delete()
                existing_user.delete()
            else:
                return Response({'status': 'Nom d\'utilisateur déjà utilisé.'}, 400)

        selected_type = data.get('types')
        doc = data.get('document_justificatif')

        if selected_type != 'cultivateurs' and not doc:
            return Response({'status': 'Document justificatif requis pour les multiplicateurs'}, 400)

        user = User(**user_data)
        user.set_password(user_data['password'])
        user.is_active = selected_type == 'cultivateurs'
        user.is_active = True
        user.save()
        user.groups.set(groups)

        multiplicator = Multiplicator.objects.create(user=user, created_by=request.user if request.user.is_authenticated else None, **data)

        superusers = User.objects.filter(is_superuser=True, email__isnull=False)
        recipient_list = [su.email for su in superusers]
        send_mail(
            subject="Nouvelle demande de multiplicateur",
            message=f"Un nouvel utilisateur a soumis une demande.\nNom : {user.get_full_name()}\nEmail : {user.email}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=recipient_list,  
        )

        return Response(MultiplicatorSerializer(multiplicator).data, 201)
    
    def get_queryset(self):
        user = self.request.user

        if user.is_superuser:
            return Multiplicator.objects.all()

        if not user.is_authenticated:
            return Multiplicator.objects.none() 

        try:
            m = Multiplicator.objects.get(user=user)
        except Multiplicator.DoesNotExist:
            return Multiplicator.objects.none()  
        
        base_qs = Multiplicator.objects.filter(pk=m.pk)

        if not m.is_validated:
            return base_qs

        if m.types == 'cultivateurs':
            return base_qs

        return base_qs
    
class MultiplicatorRoleViewset(viewsets.ModelViewSet):
    authentication_classes = [SessionAuthentication, JWTAuthentication]
    permission_classes = [IsAuthenticated]
    queryset = MultiplicatorRole.objects.all()
    serializer_class = MultiplicatorRoleSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['type_multiplicator', 'is_validated', 'multiplicator__user__username']

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return MultiplicatorRole.objects.all()
        return MultiplicatorRole.objects.filter(multiplicator__user=user)

   
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            multiplicator = Multiplicator.objects.get(user=request.user)
        except Multiplicator.DoesNotExist:
            return Response({"status":"Vous devez d'abord être enregistré comme multiplicateur."})

        role_type = serializer.validated_data['type_multiplicator']

        if MultiplicatorRole.objects.filter(multiplicator=multiplicator, type_multiplicator=role_type).exists():
            return Response(
                {"type_multiplicator": "Ce rôle existe déjà pour ce multiplicateur."},
                400
            )

        try:
            role = serializer.save(
                multiplicator=multiplicator,
                created_by=request.user
            )
        except Exception:
            return Response(
                {"detail": "Ce rôle a déjà été enregistré."},
               400
            )

        superusers = User.objects.filter(is_superuser=True, email__isnull=False)
        recipient_list = [su.email for su in superusers if su.email]
        if recipient_list:
            send_mail(
                subject="Nouveau rôle à valider",
                message=(
                    f"Un nouveau rôle « {role.type_multiplicator} » "
                    f"a été demandé par {role.multiplicator.user.username}.\n\n"
                    "Veuillez le valider dans l'interface d'administration."
                ),
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=recipient_list,
                fail_silently=True
            )

        headers = self.get_success_headers(serializer.data)
        return Response(
            MultiplicatorRoleSerializer(role).data,
            201,
            headers=headers
        )


class PlantViewset(viewsets.ModelViewSet):
    authentication_classes = [SessionAuthentication, JWTAuthentication]
    permission_classes = [IsAllowedUser]
    queryset = Plant.objects.all()
    serializer_class = PlantSerializer
    filter_backends = [DjangoFilterBackend,filters.SearchFilter]
    search_fields = ['name']
    filterset_fields = {
        'name': ['exact'],
    }

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class VarietyViewset(viewsets.ModelViewSet):
    authentication_classes = [SessionAuthentication, JWTAuthentication]
    permission_classes = [IsAllowedUser]
    queryset = Variety.objects.all()
    serializer_class = VarietySerializer
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
    filter_backends = [DjangoFilterBackend,filters.SearchFilter]
    search_fields = ['nom','plant__name']
    filterset_fields = {
        'plant__name': ['exact'],
        'nom':['exact'],
    }

ROLE_VIEW_MAP = {
    TypeMultiplicator.PRE_BASES: {TypeMultiplicator.PRE_BASES, TypeMultiplicator.BASE},
    TypeMultiplicator.BASE: {TypeMultiplicator.PRE_BASES, TypeMultiplicator.BASE, TypeMultiplicator.CERTIFIES},
    TypeMultiplicator.CERTIFIES: {TypeMultiplicator.BASE, TypeMultiplicator.CERTIFIES},
}

class StockViewset(viewsets.mixins.CreateModelMixin,mixins.RetrieveModelMixin,mixins.DestroyModelMixin,mixins.ListModelMixin,GenericViewSet):
    authentication_classes = [SessionAuthentication, JWTAuthentication]
    permission_classes = [IsAllowedUser]
    queryset = Stock.objects.all()
    serializer_class = StockSerializer
    filter_backends = [DjangoFilterBackend,filters.SearchFilter]
    search_fields = ['category','variety__plant__name','variety__nom', 'created_by']
    filterset_fields = {
        # 'category':['exact'],
        'variety__plant__name': ['exact'],
        'variety__nom': ['exact'],
        'created_at': ['gte','lte'],
        'created_by__multiplicator__province': ['exact'],
        'created_by__multiplicator__commune': ['exact'],
        'created_by__username' : ['exact']
    }

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user
        try:
            multiplicator = Multiplicator.objects.get(user=user,is_validated=True)
        except Multiplicator.DoesNotExist:
            return Response({"status": "Vous devez être enregistré comme multiplicateur."}, 403)

        allowed = set()
        if multiplicator.type_multiplicator:
            allowed.add(multiplicator.type_multiplicator)
        allowed.update(r.type_multiplicator for r in multiplicator.roles.all())

        category = serializer.validated_data['category']
        if category not in allowed:
            return Response(
                {"category": f"Vous ne pouvez créer que des stocks de type : {', '.join(sorted(allowed))}."},
                403
            )

        stock = serializer.save(created_by=user)

        superusers = User.objects.filter(is_superuser=True, email__isnull=False)
        recipient_list = [su.email for su in superusers if su.email]
        if recipient_list:
            send_mail(
                subject="Nouvelle requête de validation de stock",
                message=(
                    f"Le multiplicateur {user.username} a ajouté un nouveau stock :\n"
                    f"• Variété : {stock.variety.nom} ({stock.category})\n"
                    f"• Quantité : {stock.qte_totale}"
                ),
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=recipient_list,
                fail_silently=True,
            )

        return Response(StockSerializer(stock).data, 201)
    
    def get_queryset(self):
        user = self.request.user
        qs = super().get_queryset()

        if user.is_superuser:
            return qs

        try:
            mult = Multiplicator.objects.get(user=user)
        except Multiplicator.DoesNotExist:
            return qs.none()

        user_varieties = set(Stock.objects.filter(created_by=user).values_list('variety_id', flat=True))

        base_qs = qs.filter(
            Q(created_by=user) | 
            Q(validated_by__isnull=False) 
        )

        if mult.types == 'cultivateurs':
            return base_qs.filter(category=TypeMultiplicator.CERTIFIES,is_validated=True)

        assigned_roles = set()
        if mult.type_multiplicator:
            assigned_roles.add(mult.type_multiplicator)
        assigned_roles.update(role.type_multiplicator for role in mult.roles.all())

        allowed_categories = set()
        for role in assigned_roles:
            if role == TypeMultiplicator.PRE_BASES:
                allowed_categories.update([TypeMultiplicator.PRE_BASES, TypeMultiplicator.BASE])
            elif role == TypeMultiplicator.BASE:
                allowed_categories.update([TypeMultiplicator.PRE_BASES, TypeMultiplicator.BASE, TypeMultiplicator.CERTIFIES])
            elif role == TypeMultiplicator.CERTIFIES:
                allowed_categories.update([TypeMultiplicator.BASE, TypeMultiplicator.CERTIFIES])

        filtered_qs = base_qs.filter(category__in=allowed_categories)
        
        if user_varieties:
            return filtered_qs.filter(
                Q(created_by=user) | 
                Q(variety_id__in=user_varieties)  
            )
        else:
            return filtered_qs.filter(created_by=user)

class CommandeViewset(viewsets.mixins.CreateModelMixin,mixins.RetrieveModelMixin,mixins.DestroyModelMixin,mixins.ListModelMixin,GenericViewSet):
    queryset = Commande.objects.filter(is_deleted=False)
    serializer_class = CommandeSerializer
    permission_classes = [IsAllowedUser]
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data  = serializer.validated_data
        stock = data['stock']
        qty   = data['quantite']
        user  = request.user

        try:
            m_acheteur = Multiplicator.objects.get(user=user)
        except Multiplicator.DoesNotExist:
            return Response({"status":"Vous devez être enregistré comme multiplicateur."})
        vendeur_user = stock.created_by
        m_vendeur = Multiplicator.objects.get(user=vendeur_user)
        
        variety = stock.variety

        if stock.validated_by is None:
             return Response({"status": "Impossible de commander sur un stock non validé."}, 403)

        if m_acheteur.types == 'cultivateurs':
            if m_vendeur.type_multiplicator != 'Certifiés':
                return Response({"status": "Un cultivateur ne peut commander que chez un certifiés."},403)

        elif m_acheteur.type_multiplicator == 'Pré_Bases':
            if m_vendeur.type_multiplicator != 'Pré_Bases' or stock.variety != variety:
                return Response({"status": "Un Pré_Base ne peut commander que chez un autre Pré_Base pour la même variété."}, 403)

        elif m_acheteur.type_multiplicator == 'Base':
            if m_vendeur.type_multiplicator != 'Pré_Bases':
                return Response({"status": "Un Base ne peut commander que chez un Pré_Bases."},403)
            own_varieties = Stock.objects.filter(created_by=user).values_list('variety', flat=True)
            if variety.id not in own_varieties:
                return Response({"status": "Vous ne pouvez commander que des variétés que vous gérez vous-même."},403)

        elif m_acheteur.type_multiplicator == 'Certifiés':
            if m_vendeur.type_multiplicator != 'Base':
                return Response({"status": "Un Certifiés ne peut commander que chez un Base."},403)
            own_varieties = Stock.objects.filter(created_by=user).values_list('variety', flat=True)
            if variety.id not in own_varieties:
                return Response(
                    {"status": "Vous ne pouvez commander que des variétés que vous gérez vous-même."},403)

        if stock.qte_restante < qty:
            return Response({"status": "Stock insuffisant sur ce lot."},400)

        commande = Commande.objects.create(
            acheteur=user,
            stock=stock,
            quantite=qty,
        )

        return Response(CommandeSerializer(commande).data,201)
    
    @transaction.atomic
    @action(detail=True, methods=['get'], permission_classes=[IsSuperuserOrMultiplicator],url_path='delivered',url_name='delivered')
    def delivered(self, request, *args, **kwargs):
        instance = self.get_object()
        user = request.user
        if instance.is_delivered:
            return Response({"status": "Cette commande a déjà été livrée."}, 400)
        
        if instance.stock.created_by != user:
            return Response({"status": "Vous ne pouvez livrer que les commandes faites dans votre stock."}, 403)

        instance.is_delivered = True
        instance.delivered_date = timezone.now()
        instance.montant_paye = instance.montant_total
        instance.save()

        stock = instance.stock
        stock.qte_restante = F('qte_restante') - instance.quantite
        stock.save()
        stock.refresh_from_db()

        return Response({'status': 'Commande livrée avec succès'}, 200)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.is_delivered:
            return Response({"status":"Vous ne pouvez pas supprimer une commande deja livree"})
        instance.is_deleted = True
        instance.save()
        return Response({'status': 'Commande annulée'}, 204)


class NoteViewset(viewsets.mixins.CreateModelMixin,mixins.RetrieveModelMixin,mixins.DestroyModelMixin,mixins.ListModelMixin,GenericViewSet):
    queryset = Note.objects.all()
    serializer_class = NoteSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        created_by = request.user
        
        commande = serializer.validated_data['commande']
        if not commande.is_delivered:
            return Response({"status": "Vous ne pouvez noter que les commandes livrées"},400)
        
        if commande.acheteur != request.user:
            return Response({"status": "Vous ne pouvez noter que vos propres commandes"},403)
        serializer.save(created_by=created_by)
        return Response(serializer.data, 201)


class PerteViewset(viewsets.ModelViewSet):
    authentication_classes = [SessionAuthentication, JWTAuthentication]
    permission_classes = [IsAllowedUser]
    serializer_class = PerteSerializer
    queryset = Perte.objects.none()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    search_fields = ['created_at']
    filterset_fields = {
        'created_at': ['gte', 'lte'],
    }

    def get_queryset(self):
        user=self.request.user
        if user.is_superuser:
            return Perte.objects.all()
        return Perte.objects.filter(
            created_by=self.request.user
        )
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        stock = data['stock']
        quantite = data['quantite']
        user = request.user

        if not stock.validated_by:
            return Response({"status": "Impossible : le stock n'a pas été validé"}, 403)

        if quantite <= 0:
            return Response({"status": "La quantité doit être positive"}, 400)

        if quantite > stock.qte_restante:
            return Response({"status": f"La perte dépasse le stock disponible ({stock.qte_restante} unités)"}, 400)

        montant_perdu = quantite * stock.prix_vente_unitaire

        perte = Perte.objects.create(
            stock=stock,
            quantite=quantite,
            montant_perdu=montant_perdu,
            created_by=user
        )

        stock.qte_restante = F('qte_restante') - quantite
        stock.save()
        stock.refresh_from_db()

        return Response(PerteSerializer(perte).data, 201)

    @transaction.atomic
    def destroy(self, request, *args, **kwargs):
        perte = self.get_object()
        stock = perte.stock

        stock.qte_restante = F('qte_restante') + perte.quantite
        stock.save()
        stock.refresh_from_db()

        perte.delete()

        return Response({"status": "Perte annulée et stock rétabli"}, 204)