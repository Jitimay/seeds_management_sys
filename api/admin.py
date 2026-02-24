from django.contrib import admin
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from django.contrib import messages
from django.http import JsonResponse
from django.template.response import TemplateResponse
from .models import *

@admin.action(description="Valider les multiplicateurs sélectionnés")
def valider_multiplicateurs(modeladmin, request, queryset):
    valides, ignores = 0, 0
    for multiplicator in queryset:
        if multiplicator.types != 'multiplicateurs' or multiplicator.is_validated:
            ignores += 1
            continue
        user = multiplicator.user
        multiplicator.is_validated = True
        multiplicator.validated_at = timezone.now()
        user.is_active = True
        multiplicator.save()
        user.save()
        send_mail(
            "Validation de votre compte",
            f"Bonjour {user.username},\n\nVotre compte multiplicateur a été validé.",
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
        )
        valides += 1
    if valides:
        modeladmin.message_user(request, f"{valides} multiplicateur(s) validé(s).", messages.SUCCESS)
    if ignores:
        modeladmin.message_user(request, f"{ignores} ignoré(s).", messages.WARNING)

@admin.action(description="Valider les rôles sélectionnés")
def valider_roles(modeladmin, request, queryset):
    for role in queryset:
        if not role.is_validated:
            role.is_validated = True
            role.validated_at = timezone.now()
            role.validated_by = request.user
            role.save()
            user = role.multiplicator.user
            send_mail(
                "Validation de votre nouveau rôle",
                f"Bonjour {user.username},\n\nVotre rôle « {role.get_type_multiplicator_display()} » a été validé.",
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
            )

@admin.action(description="Refuser les multiplicateurs sélectionnés (avec motif)")
def refuser_multiplicateurs_avec_motif(modeladmin, request, queryset):
    if request.method == 'POST' and 'motif_refus' in request.POST:
        motif = request.POST.get('motif_refus', '').strip()
        if motif:
            refuses = 0
            for multiplicator in queryset:
                if not multiplicator.is_validated:
                    multiplicator.validation_reason = motif
                    multiplicator.save()
                    user = multiplicator.user
                    send_mail(
                        "Demande refusée",
                        f"Bonjour {user.username},\n\nVotre demande de multiplicateur a été refusée pour la raison suivante :\n\n{motif}",
                        settings.DEFAULT_FROM_EMAIL,
                        [user.email],
                    )
                    refuses += 1
            modeladmin.message_user(request, f"{refuses} multiplicateur(s) refusé(s).", messages.SUCCESS)
            return
        else:
            modeladmin.message_user(request, "Veuillez saisir un motif de refus.", messages.ERROR)
    
    context = {
        'title': 'Refuser les multiplicateurs sélectionnés',
        'objects': queryset,
        'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        'action_name': 'refuser_multiplicateurs_avec_motif',
        'opts': modeladmin.model._meta,
    }
    
    return TemplateResponse(request, 'admin/saisie_motif_refus.html', context)

@admin.action(description="Refuser les rôles sélectionnés (avec motif)")
def refuser_roles_avec_motif(modeladmin, request, queryset):
    if request.method == 'POST' and 'motif_refus' in request.POST:
        motif = request.POST.get('motif_refus', '').strip()
        if motif:
            refuses = 0
            for role in queryset:
                if not role.is_validated:
                    role.validation_reason = motif
                    role.save()
                    user = role.multiplicator.user
                    send_mail(
                        "Refus de votre demande de rôle",
                        f"Bonjour {user.username},\n\nVotre rôle « {role.get_type_multiplicator_display()} » a été refusé.\n\nRaison : {motif}",
                        settings.DEFAULT_FROM_EMAIL,
                        [user.email],
                    )
                    refuses += 1
            modeladmin.message_user(request, f"{refuses} rôle(s) refusé(s).", messages.SUCCESS)
            return
        else:
            modeladmin.message_user(request, "Veuillez saisir un motif de refus.", messages.ERROR)
    
    context = {
        'title': 'Refuser les rôles sélectionnés',
        'objects': queryset,
        'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        'action_name': 'refuser_roles_avec_motif',
        'opts': modeladmin.model._meta,
    }
    
    return TemplateResponse(request, 'admin/saisie_motif_refus.html', context)

@admin.register(Multiplicator)
class MultiplicatorAdmin(admin.ModelAdmin):
    list_display = ("user", "province", "commune", "colline", "phone_number", "types", "type_multiplicator", "all_roles_display", "is_validated")
    list_filter = ("is_validated", "province", "commune")
    search_fields = ("user__username", "province", "commune", "colline", "phone_number")
    ordering = ("province", "commune")
    actions = [valider_multiplicateurs, refuser_multiplicateurs_avec_motif]

    def has_add_permission(self, request):
        return False

    def all_roles_display(self, obj):
        roles = obj.roles.values_list('type_multiplicator', flat=True)
        return ", ".join(roles) if roles else "-"
    all_roles_display.short_description = "Rôles"

@admin.register(MultiplicatorRole)
class MultiplicatorRoleAdmin(admin.ModelAdmin):
    list_display = ('multiplicator', 'type_multiplicator', 'is_validated', 'validated_by', 'validated_at')
    list_filter = ('type_multiplicator', 'is_validated')
    actions = [valider_roles, refuser_roles_avec_motif]

    def has_add_permission(self, request):
        return False
    def has_change_permission(self, request, obj=None):
        return False

@admin.action(description="Valider les stocks sélectionnés")
def validate_stocks(modeladmin, request, queryset):
    for stock in queryset:
        if not stock.validated_by:
            stock.validated_at = timezone.now()
            stock.validated_by = request.user
            stock.save()
            user = stock.created_by
            send_mail(
                "Stock validé",
                f"Bonjour {user.username},\n\nVotre stock de {stock.variety.nom} ({stock.category}) a été validé.",
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
            )

@admin.register(Stock)
class StockAdmin(admin.ModelAdmin):
    list_display = ('variety', 'category', 'qte_totale', 'qte_restante', 'validated_by', 'validated_at')
    list_filter = ('category', 'variety__plant__name')
    actions = [validate_stocks]
    readonly_fields = ('qte_restante', 'validated_at', 'validated_by')

    def has_add_permission(self, request):
        return False
    def has_change_permission(self, request, obj=None):
        return False

@admin.register(Plant)
class PlantAdmin(admin.ModelAdmin):
	list_display = ('name', 'created_by', 'created_at')
	search_fields = ('name',)
	
@admin.register(Variety)
class VarietyAdmin(admin.ModelAdmin):
    list_display = ('nom', 'plant', 'nom_kirundi', 'annee_diffusion')
    list_filter = ('plant',)
    search_fields = ('nom', 'nom_kirundi')

@admin.register(Commande)
class CommandeAdmin(admin.ModelAdmin):
	list_display = ('acheteur', 'stock', 'quantite', 'montant_total', 'is_delivered', 'created_at')
	list_filter = ('is_delivered', 'created_at')
	search_fields = ('acheteur__username', 'stock__variety__nom')
	
	def has_add_permission(self, request):
		return False
	def has_change_permission(self, request, obj=None):
		return False
	def has_delete_permission(self, request, obj=None):
		return False

@admin.register(Note)
class NoteAdmin(admin.ModelAdmin):
	list_display = ('stock', 'commande', 'etoiles', 'commentaire', 'created_by', 'created_at')
	list_filter = ('etoiles',)
	search_fields = ('stock__variety__nom', 'commentaire')
	
	def has_add_permission(self, request):
		return False
	def has_change_permission(self, request, obj=None):
		return False
	def has_delete_permission(self, request, obj=None):
		return False

@admin.register(Perte)
class PerteAdmin(admin.ModelAdmin):
	list_display = ('stock', 'quantite', 'montant_perdu', 'created_by', 'created_at')
	search_fields = ('stock__variety__nom', 'details')
	
	def has_add_permission(self, request):
		return False
	def has_change_permission(self, request, obj=None):
		return False
	def has_delete_permission(self, request, obj=None):
		return False