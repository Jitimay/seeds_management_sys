from rest_framework import serializers
from .models import *
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password

from django.utils.http import urlsafe_base64_decode
from django.utils.encoding import force_str
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import generics

from django.utils.http import urlsafe_base64_decode
from django.utils.encoding import force_str
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.contrib.auth import get_user_model



class TokenPairSerializer(TokenObtainPairSerializer):
    
    def validate(self, attrs):
        identifier = attrs.get('username')
        if '@' in identifier:
            try:
                user_obj = User.objects.get(email__iexact=identifier)
            except User.DoesNotExist:
                raise serializers.ValidationError("Aucun utilisateur avec cet e‑mail.")
            attrs['username'] = user_obj.username

        data = super().validate(attrs)
        user = self.user

        if user.is_superuser:
            data.update({
                'username': user.username,
                'fullname': f"{user.first_name} {user.last_name}",
                'role': 'superuser'
            })
            return data

        try:
            m = Multiplicator.objects.get(user=user)
        except Multiplicator.DoesNotExist:
            raise serializers.ValidationError("Vous n'êtes ni cultivateur ni multiplicateur.")

        data.update({
            'username': user.username,
            'fullname': f"{user.first_name} {user.last_name}",
            'email': m.user.email,
            'type_multiplicator': m.type_multiplicator,
            'province': m.province,
            'commune': m.commune,
            'colline': m.colline,
            'phone_number': m.phone_number,
            'other_phone_number': m.other_phone_number,
            'is_validated': m.is_validated,
            'document_justificatif': m.document_justificatif.url if m.document_justificatif else None,
            'created_at': m.created_at.isoformat(),
        })

        return data
        

User = get_user_model()

class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Aucun utilisateur trouvé avec cet email.")
        return value


class PasswordResetConfirmSerializer(serializers.Serializer):
     new_password = serializers.CharField(write_only=True, min_length=8)

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    class Meta:
        model = User
        exclude = ('last_login', 'is_staff', 'date_joined',
                   'is_superuser', 'groups', 'user_permissions', 'is_active')

class UserPublicSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']  

class SimpleMultiplicatorSerializer(serializers.ModelSerializer):
    user = UserPublicSerializer()

    class Meta:
        model = Multiplicator
        fields = ['id', 'user', 'types', 'province', 'commune', 'colline','type_multiplicator','is_validated','created_by']

class MultiplicatorRoleSerializer(serializers.ModelSerializer):
    multiplicator = SimpleMultiplicatorSerializer(read_only=True)
    created_by = serializers.SlugRelatedField(slug_field='username', read_only=True)

    class Meta:
        model = MultiplicatorRole
        fields = '__all__'
        read_only_fields = ['is_validated', 'validated_at', 'validated_by', 'created_at']

    def to_representation(self, obj):
        rep = super().to_representation(obj)
        rep['multiplicator'] = SimpleMultiplicatorSerializer(obj.multiplicator).data if obj.multiplicator else None
        rep['created_by'] = obj.created_by.username if obj.created_by else None
        # rep['type_multiplicator_display'] = obj.get_type_multiplicator_display()
        return rep
    
   
class MultiplicatorSerializer(serializers.ModelSerializer):

    user = UserSerializer()
    types = serializers.ChoiceField(choices=Multiplicator.TYPE_CHOICES)
    # roles = MultiplicatorRoleSerializer(many=True, read_only=True)
    all_roles = serializers.SerializerMethodField()

    def get_all_roles(self, obj):
        return [r.type_multiplicator for r in obj.roles.all()]

    def to_representation(self, obj):
        rep = super().to_representation(obj)
        rep['user'] = UserSerializer(obj.user).data if obj.user else None      
        rep['created_by'] = obj.created_by.username if obj.created_by else None
        return rep  

    class Meta:
        model = Multiplicator
        fields = "__all__"
        read_only_fields = (
            'is_validated',
            'validation_reason',  
        )
        
    def validate(self, data):
        if data['types'] == 'multiplicateurs' and not data.get('type_multiplicator'):
            raise serializers.ValidationError({
                'type_multiplicator': "Champ requis pour les multiplicateurs."
            })
        return data
    
class MultiplicatorProfileSerializer(serializers.ModelSerializer):
    user = UserPublicSerializer(read_only=True)
    all_roles = serializers.SerializerMethodField()

    def get_all_roles(self, obj):
        return [r.type_multiplicator for r in obj.roles.all()]

    class Meta:
        model = Multiplicator
        fields = ['id','user','types','type_multiplicator','province','is_validated','all_roles']

    
class VarietySerializer(serializers.ModelSerializer):
    plant_name = serializers.CharField(source='plant.name', read_only=True)

    class Meta:
        model = Variety
        fields = "__all__"
class PlantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Plant
        fields = "__all__"
class StockSerializer(serializers.ModelSerializer): 
    variety = serializers.PrimaryKeyRelatedField(queryset=Variety.objects.all())
    created_by = UserPublicSerializer(read_only=True)
    validated_by = UserPublicSerializer(read_only=True)
    
    def to_representation(self, obj):
        rep = super().to_representation(obj)
        # rep['variety'] = VarietySerializer(obj.variety).data
        return rep
    
    class Meta:
        model = Stock
        fields = "__all__"

class StockPublicSerializer(serializers.ModelSerializer):
    variety_info = VarietySerializer(source='variety', read_only=True)
    created_by = MultiplicatorProfileSerializer(source='created_by.multiplicator', read_only=True)

    class Meta:
        model = Stock
        fields = ['id','variety_info','created_by','category','qte_totale','qte_restante','prix_vente_unitaire','validated_at']  


class CommandeSerializer(serializers.ModelSerializer):
    acheteur = MultiplicatorProfileSerializer(source='acheteur.multiplicator', read_only=True)   
    def to_representation(self, obj):
        rep = super().to_representation(obj)
        rep['stock'] = StockPublicSerializer(obj.stock).data if obj.stock else None      
        return rep  
   
    class Meta:
        model = Commande
        fields = '__all__'


class NoteSerializer(serializers.ModelSerializer):

    class Meta:
        model = Note
        fields = '__all__'


class PerteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Perte
        fields = '__all__'
        