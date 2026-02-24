# from django.views.decorators.csrf import csrf_exempt
# from django.http import HttpResponse
# from .models import Seed, Stock, Vente, Multiplicator
# from django.utils import timezone
# from django.core.cache import cache


# def send_sms(to_number, message):
#     # TODO:
#     print(f"SMS envoyé à {to_number}: {message}")

# @csrf_exempt
# def ussd_callback(request):
#     session_id = request.POST.get("sessionId", "")
#     service_code = request.POST.get("serviceCode", "")
#     phone_number = request.POST.get("phoneNumber", "").replace("+", "").strip()
#     text = request.POST.get("text", "")

#     # Store session data
#     session_data = cache.get(session_id) or {}
#     if not session_data:
#         cache.set(session_id, {"start_time": timezone.now()}, timeout=300) 
#     # Log USSD session
#     print(f"New USSD Session: {session_id}")
#     print(f"Service Code: {service_code}")
#     print(f"Phone Number: {phone_number}")

#     response = ""
#     menu = text.split("*")

#     try:
#         multiplicator = Multiplicator.objects.get(phone_number__icontains=phone_number[-9:])
#         user = multiplicator.user
#     except Multiplicator.DoesNotExist:
#         return HttpResponse("END Votre numéro n'est pas enregistré dans notre système.", content_type="text/plain")

#     # Menu principal
#     if text == "":
#         response = f"Bienvenue {multiplicator.type}.\n"
#         response += "1. Voir les semences disponibles\n"
#         response += "2. Acheter une semence\n"
#         if multiplicator.type in ['Pré_Bases', 'Bases', 'Certifiés']:
#             response += "3. Voir le stock disponible\n"

#     # Option 1 - Liste des semences
#     elif menu[0] == "1":
#         seeds = Seed.objects.filter(disponible=True)
#         if seeds.exists():
#             response = "Semences disponibles:\n"
#             for i, seed in enumerate(seeds, 1):
#                 response += f"{i}. {seed.plant.name} ({seed.category}) - {seed.prix} BIF\n"
#             response += "\n0. Retour"
#         else:
#             response = "END Aucune semence disponible."

#     # Option 2 - Acheter une semence
#     elif menu[0] == "2":
#         seeds = list(Seed.objects.filter(disponible=True))
#         if len(menu) == 1:
#             response = "Choisissez une semence à acheter:\n"
#             for i, seed in enumerate(seeds, 1):
#                 response += f"{i}. {seed.plant.name} - {seed.prix} BIF\n"
#         elif len(menu) == 2:
#             try:
#                 selected_index = int(menu[1]) - 1
#                 seed = seeds[selected_index]
#                 response = f"Entrez la quantité à acheter pour {seed.plant.name}:"
#             except (IndexError, ValueError):
#                 response = "END Choix invalide."
#         elif len(menu) == 3:
#             try:
#                 selected_index = int(menu[1]) - 1
#                 quantite = int(menu[2])
#                 seed = seeds[selected_index]

#                 stock = Stock.objects.first()
#                 Vente.objects.create(
#                     quantite_vendue=quantite,
#                     prix_de_vente=str(seed.prix),
#                     stock=stock,
#                     created_by=user
#                 )

#                 sms_message = f"Achat confirmé: {quantite} unités de {seed.plant.name} à {seed.prix} BIF."
#                 send_sms(phone_number, sms_message)

#                 response = f"END Achat effectué. Détails envoyés par SMS."
#             except Exception as e:
#                 response = "END Erreur lors de l'achat."

#     # Option 3 - Voir le stock
#     elif menu[0] == "3":
#         if multiplicator.type not in ['Pré_Bases', 'Bases', 'Certifiés']:
#             response = "END Désolé, cette option est réservée aux Pré_Bases, Bases et Certifiés."
#         else:
#             stocks = Stock.objects.all()
#             if stocks.exists():
#                 response = "END Stocks disponibles:\n"
#                 for stock in stocks:
#                     response += f"{stock.quantite} unités restantes\n"
#             else:
#                 response = "END Aucun stock disponible."

#     else:
#         response = "END Option invalide."

#     return HttpResponse(response, content_type="text/plain")
