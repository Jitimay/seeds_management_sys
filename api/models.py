from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
import time
from django.core.validators import MinValueValidator, MaxValueValidator

class TypeMultiplicator(models.TextChoices):
    PRE_BASES = 'Pré_Bases', 'Pré_Bases'
    BASE = 'Base', 'Base'
    CERTIFIES = 'Certifiés', 'Certifiés'

class Multiplicator(models.Model):
	TYPE_CHOICES = (
		('multiplicateurs', 'multiplicateurs'),
		('cultivateurs', 'cultivateurs'),
	)
	id = models.AutoField(primary_key=True)
	user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='multiplicator')
	type_multiplicator = models.CharField(choices=TypeMultiplicator.choices, max_length=100,  blank=True, null=True)
	province = models.CharField(max_length=30)
	commune = models.CharField(max_length=30)
	colline = models.CharField(max_length=20)
	phone_number = models.CharField(max_length=21)
	other_phone_number = models.CharField(max_length=21, null=True, blank=True)
	types = models.CharField(choices=TYPE_CHOICES, max_length=100)
	document_justificatif = models.FileField(upload_to='documents_multiplicateurs/',null=True,blank=True,)
	is_validated = models.BooleanField(default=False,editable=False)
	validated_at = models.DateTimeField(editable=False,blank=True, null=True)
	validation_reason = models.CharField(max_length=255, blank=True, null=True,help_text="Raison du refus, si applicable")
	created_at = models.DateTimeField(default=timezone.now, editable=False)
	created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False,related_name='created_multiplicateurs',null=True, blank=True)

	def __str__(self):
		return f'{self.user.username} {self.commune} {self.province} {self.phone_number}'

class MultiplicatorRole(models.Model):
	id = models.AutoField(primary_key=True)
	multiplicator = models.ForeignKey('Multiplicator', on_delete=models.CASCADE, related_name='roles')
	type_multiplicator = models.CharField(max_length=20, choices=TypeMultiplicator.choices)
	document = models.FileField(upload_to='docs_roles/')
	is_validated = models.BooleanField(default=False)
	validated_at = models.DateTimeField(null=True, blank=True,editable=False)
	validated_by = models.ForeignKey(User, null=True, blank=True, on_delete=models.PROTECT, related_name='validated_roles')
	validation_reason = models.CharField(max_length=255, blank=True, null=True,help_text="Raison du refus, si applicable")
	created_at = models.DateTimeField(auto_now_add=True)
	created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False, related_name='created_roles')

	class Meta:
		unique_together = ('multiplicator', 'type_multiplicator')

	def __str__(self):
		return f"{self.multiplicator} - {self.type_multiplicator}"

class PasswordResetToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.CharField(max_length=100, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

class Plant(models.Model):
	id = models.AutoField(primary_key=True)
	name = models.CharField(max_length=50, unique=True)
	created_at = models.DateTimeField(default=timezone.now, editable=False)
	created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False)

	def __str__(self):
		return f'{self.name}'


class Variety(models.Model):
	id = models.AutoField(primary_key=True)
	plant = models.ForeignKey(Plant, on_delete=models.CASCADE)
	nom_botanique = models.CharField(max_length=50, blank=True, null=True)
	nom = models.CharField(max_length=30,verbose_name="Nom Commun")  
	nom_variete = models.CharField(max_length=50, blank=True, null=True)
	type_varietal = models.CharField(max_length=50, blank=True, null=True)
	nom_kirundi = models.CharField(max_length=50, blank=True, null=True)  
	photo = models.ImageField(blank=True,upload_to="media/")
	
	code_origine = models.CharField(max_length=30, blank=True, null=True)
	centre_origine = models.CharField(max_length=100, blank=True, null=True)
	obtenteur = models.CharField(max_length=50, blank=True, null=True)
	mainteneur = models.CharField(max_length=50, blank=True, null=True)
	annee_diffusion = models.PositiveIntegerField(blank=True, null=True)
	date_inscription = models.DateField(blank=True, null=True)
	numero_enregistrement = models.CharField(max_length=20, blank=True, null=True)

	service_examen = models.CharField(max_length=100, blank=True, null=True)
	station_examen = models.CharField(max_length=100, blank=True, null=True)
	periode_examen = models.CharField(max_length=100, blank=True, null=True)
	
	zone_culture = models.CharField(max_length=100, blank=True, null=True)
	rendement = models.CharField(max_length=50, blank=True, null=True)
	cycle_vegetatif = models.CharField(max_length=50, blank=True, null=True)

	
	created_at = models.DateTimeField(default=timezone.now, editable=False)
	created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False)

	def __str__(self):
		return f"{self.nom} ({self.plant.name})"
	
	class Meta:
		unique_together = 'nom' , 'plant'


	

class Stock(models.Model):
	id = models.AutoField(primary_key=True)
	category = models.CharField(max_length=30,choices=TypeMultiplicator.choices, verbose_name='Category')
	variety = models.ForeignKey("Variety", on_delete=models.PROTECT)
	details = models.CharField(max_length=64,help_text="precise si c'est par kilos,unites ou autre chose", null=True, blank=True)
	qte_totale = models.FloatField(default=0,verbose_name="quantite totale")
	qte_restante = models.FloatField(default=0, verbose_name='quantité restante',editable=False)
	prix_vente_unitaire = models.PositiveIntegerField(default=0, verbose_name="Prix de vente unitaire")
	date_expiration = models.DateField(blank=True, null=True)
	created_at = models.DateTimeField(auto_now_add=True)
	created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False,related_name='created_stocks')
	validated_at = models.DateTimeField(editable=False,blank=True, null=True)
	validated_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False, related_name='validated_stocks', null=True, blank=True)

	def save(self, *args, **kwargs):
		if not self.pk: 
			self.qte_restante = self.qte_totale
		super().save(*args, **kwargs)

	def __str__(self):
		return f"{self.category} - {self.variety.nom} - {self.qte_restante}/{self.qte_totale}"
	
	class Meta:
		unique_together = ('category', 'created_by', 'variety')
		constraints = [
			models.CheckConstraint(
				check=models.Q(qte_totale__gte=0),
				name='quantite_totale_cannot_be_negative',
			),
			models.CheckConstraint(
				check=models.Q(qte_restante__gte=0),
				name='quantite_restante_cannot_be_negative',
			),
		]
class Commande(models.Model):
	id = models.AutoField(primary_key=True)
	is_deleted = models.BooleanField(default=False, editable=False)
	acheteur = models.ForeignKey(User, on_delete=models.PROTECT, editable=False, related_name='commandes_achetees')
	quantite = models.FloatField(default=0)
	prix_unitaire = models.PositiveIntegerField(editable=False, null=True)
	montant_total = models.PositiveIntegerField(editable=False, null=True)
	montant_paye = models.PositiveIntegerField(default=0, editable=False)
	is_delivered = models.BooleanField(default=False, editable=False)
	delivered_date = models.DateTimeField(null=True, blank=True, editable=False)
	created_at = models.DateTimeField(auto_now_add=True)
	stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
	
	def save(self, *args, **kwargs):
		if not self.prix_unitaire:
			self.prix_unitaire = self.stock.prix_vente_unitaire
		if not self.montant_total:
			self.montant_total = self.prix_unitaire * self.quantite
		super().save(*args, **kwargs)

	def __str__(self):
		return f"{self.acheteur} - {self.stock.variety.nom} ({self.quantite}) - {self.id}"
	
	class Meta:
		verbose_name = 'Commande'
		verbose_name_plural = 'Commandes'
		constraints = [
			models.CheckConstraint(
				check=models.Q(quantite__gte=0),
				name='quantite_commande_cannot_be_negative',
			),
		]

class Note(models.Model):
    id = models.AutoField(primary_key=True)
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE, related_name='notes')
    commande = models.ForeignKey(Commande, on_delete=models.CASCADE)
    etoiles = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    commentaire = models.CharField(max_length=128, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(User, on_delete=models.PROTECT, editable=False)

    def __str__(self):
        return f"Note {self.etoiles}/5 - {self.stock.variety.nom}"


class Perte(models.Model):
	id = models.AutoField(primary_key=True,editable=False)
	stock = models.ForeignKey(Stock, on_delete=models.PROTECT)
	quantite = models.PositiveIntegerField()
	montant_perdu = models.FloatField(editable=False)
	details = models.CharField(max_length=255, blank=True, null=True)
	created_at = models.DateTimeField(auto_now_add=True)
	created_by = models.ForeignKey(User, editable=False, on_delete=models.PROTECT)

	def __str__(self):
		return f"{self.stock.variety.nom} de {self.quantite} perdu "
	
	class Meta:
		verbose_name = 'Perte'
		verbose_name_plural = 'Pertes'
		constraints = [
		models.CheckConstraint(
			check=models.Q(montant_perdu__gte="0") ,
			name="montant_perdu_perte_cannot_be_negative",
		)]


