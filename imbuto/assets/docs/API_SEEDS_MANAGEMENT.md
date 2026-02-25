# 🌱 API GESTION DES SEMENCES - BURUNDI

**BASE URL:** `https://assma.amidev.bi/`  
**Version:** 2.0 | **Date:** Février 2026

---

## 🔐 AUTHENTIFICATION

### LOGIN
**Endpoint:** `POST /login/`  
**Auth Required:** ❌ Non

**Request:**
```json
{
  "username": "john_doe",
  "password": "motdepasse123"
}
```

**Response (200):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "username": "john_doe",
  "fullname": "John Doe",
  "email": "john@example.com",
  "type_multiplicator": "Base",
  "province": "Bujumbura Mairie",
  "commune": "Mukaza",
  "colline": "Rohero",
  "phone_number": "+25779123456",
  "other_phone_number": "+25779654321",
  "is_validated": true,
  "document_justificatif": "/media/documents_multiplicateurs/doc.pdf",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### REFRESH TOKEN
**Endpoint:** `POST /refresh/`  
**Auth Required:** ❌ Non

**Request:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (200):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

## 👥 INSCRIPTION UTILISATEURS

### INSCRIPTION MULTIPLICATEUR
**Endpoint:** `POST /Multiplicator/`  
**Auth Required:** ❌ Non

**Request:**
```json
{
  "user": {
    "username": "nouveau_multiplicateur",
    "email": "nouveau@example.com",
    "first_name": "Jean",
    "last_name": "Dupont",
    "password": "motdepasse123"
  },
  "type_multiplicator": "Base",
  "province": "Gitega",
  "commune": "Gitega",
  "colline": "Mushasha",
  "phone_number": "+25779123456",
  "other_phone_number": "+25779654321",
  "types": "multiplicateurs",
  "document_justificatif": "fichier_PDF_ou_image"
}
```

**Response (201):**
```json
{
  "id": 1,
  "user": {
    "id": 5,
    "username": "nouveau_multiplicateur",
    "email": "nouveau@example.com",
    "first_name": "Jean",
    "last_name": "Dupont"
  },
  "type_multiplicator": "Base",
  "province": "Gitega",
  "commune": "Gitega",
  "colline": "Mushasha",
  "phone_number": "+25779123456",
  "other_phone_number": "+25779654321",
  "types": "multiplicateurs",
  "is_validated": false,
  "document_justificatif": "/media/documents_multiplicateurs/doc.pdf",
  "created_at": "2024-01-15T10:30:00Z",
  "all_roles": []
}
```


### INSCRIPTION CULTIVATEUR
**Endpoint:** `POST /Multiplicator/`  
**Auth Required:** ❌ Non

**Request:**
```json
{
  "user": {
    "username": "cultivateur_marie",
    "email": "marie@example.com",
    "first_name": "Marie",
    "last_name": "Nzeyimana",
    "password": "motdepasse123"
  },
  "province": "Bururi",
  "commune": "Bururi",
  "colline": "Kiganda",
  "phone_number": "+25779987654",
  "types": "cultivateurs"
}
```

**Response (201):**
```json
{
  "id": 2,
  "user": {
    "id": 6,
    "username": "cultivateur_marie",
    "email": "marie@example.com",
    "first_name": "Marie",
    "last_name": "Nzeyimana"
  },
  "province": "Bururi",
  "commune": "Bururi",
  "colline": "Kiganda",
  "phone_number": "+25779987654",
  "types": "cultivateurs",
  "is_validated": true,
  "created_at": "2024-01-15T11:00:00Z"
}
```

### LISTE MULTIPLICATEURS
**Endpoint:** `GET /Multiplicator/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `is_validated` : true/false
- `type_multiplicator` : Pré_Bases/Base/Certifiés
- `types` : multiplicateurs/cultivateurs
- `province` : nom de la province
- `commune` : nom de la commune

**Response (200):**
```json
{
  "count": 2,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "user": {
        "id": 5,
        "username": "john_doe",
        "email": "john@example.com"
      },
      "type_multiplicator": "Base",
      "province": "Gitega",
      "commune": "Gitega",
      "is_validated": true,
      "all_roles": ["Base", "Pré_Bases"]
    }
  ]
}
```

---

## 🎖️ GESTION DES RÔLES

### AJOUTER UN NOUVEAU RÔLE
**Endpoint:** `POST /Multiplicator_Roles/`  
**Auth Required:** ✅ Oui (Multiplicateur validé)

**Request:**
```json
{
  "type_multiplicator": "Pré_Bases",
  "document": "certificat_pre_bases.pdf"
}
```

**Response (201):**
```json
{
  "id": 2,
  "multiplicator": {
    "id": 1,
    "user": {
      "id": 5,
      "username": "john_doe",
      "email": "john@example.com"
    },
    "types": "multiplicateurs",
    "type_multiplicator": "Base",
    "province": "Gitega",
    "commune": "Gitega",
    "is_validated": true
  },
  "type_multiplicator": "Pré_Bases",
  "is_validated": false,
  "validated_at": null,
  "validated_by": null,
  "document": "/media/docs_roles/cert_pre_bases.pdf",
  "created_at": "2024-01-15T16:20:00Z",
  "created_by": "john_doe"
}
```

### LISTE DES RÔLES
**Endpoint:** `GET /Multiplicator_Roles/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `type_multiplicator` : Pré_Bases/Base/Certifiés
- `is_validated` : true/false

**Response (200):**
```json
{
  "count": 2,
  "results": [
    {
      "id": 1,
      "type_multiplicator": "Base",
      "is_validated": true,
      "validated_at": "2024-01-10T14:30:00Z",
      "validated_by": 1,
      "document": "/media/docs_roles/cert_base.pdf",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ]
}
```

---

## 🌾 CATALOGUE (PLANTES & VARIÉTÉS)

### CRÉER UNE PLANTE
**Endpoint:** `POST /plantes/`  
**Auth Required:** ✅ Oui (Multiplicateur validé)

**Request:**
```json
{
  "name": "Maïs"
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Maïs",
  "created_at": "2024-01-01T10:00:00Z",
  "created_by": 1
}
```

### LISTE DES PLANTES
**Endpoint:** `GET /plantes/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `name` : nom exact de la plante
- `search` : recherche partielle

**Response (200):**
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "name": "Maïs",
      "created_at": "2024-01-01T10:00:00Z",
      "created_by": 1
    },
    {
      "id": 2,
      "name": "Haricot",
      "created_at": "2024-01-02T10:00:00Z",
      "created_by": 1
    }
  ]
}
```


### CRÉER UNE VARIÉTÉ
**Endpoint:** `POST /variete/`  
**Auth Required:** ✅ Oui (Multiplicateur validé)

**Request:**
```json
{
  "plant": 1,
  "nom_botanique": "Zea mays L.",
  "nom": "Maïs Blanc Précoce",
  "nom_variete": "ZM521",
  "type_varietal": "Variété améliorée",
  "nom_kirundi": "Ibigori byera",
  "code_origine": "ZM521-BDI",
  "centre_origine": "ISABU - Gitega",
  "obtenteur": "Institut des Sciences Agronomiques du Burundi",
  "mainteneur": "ISABU",
  "annee_diffusion": 2020,
  "date_inscription": "2020-03-15",
  "numero_enregistrement": "VAR-2020-001",
  "service_examen": "Service National des Semences",
  "station_examen": "Station de Gitega",
  "periode_examen": "2018-2020",
  "zone_culture": "Toutes les zones agro-écologiques",
  "rendement": "4-6 tonnes/hectare",
  "cycle_vegetatif": "90-110 jours"
}
```

**Response (201):**
```json
{
  "id": 1,
  "plant": 1,
  "plant_name": "Maïs",
  "nom_botanique": "Zea mays L.",
  "nom": "Maïs Blanc Précoce",
  "nom_variete": "ZM521",
  "type_varietal": "Variété améliorée",
  "nom_kirundi": "Ibigori byera",
  "code_origine": "ZM521-BDI",
  "centre_origine": "ISABU - Gitega",
  "obtenteur": "Institut des Sciences Agronomiques du Burundi",
  "mainteneur": "ISABU",
  "annee_diffusion": 2020,
  "date_inscription": "2020-03-15",
  "numero_enregistrement": "VAR-2020-001",
  "zone_culture": "Toutes les zones agro-écologiques",
  "rendement": "4-6 tonnes/hectare",
  "cycle_vegetatif": "90-110 jours",
  "created_at": "2024-01-05T10:00:00Z",
  "created_by": 1
}
```

### LISTE DES VARIÉTÉS
**Endpoint:** `GET /variete/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `plant__name` : nom de la plante
- `nom` : nom exact de la variété
- `search` : recherche partielle

**Response (200):**
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "plant": 1,
      "plant_name": "Maïs",
      "nom": "Maïs Blanc Précoce",
      "nom_variete": "ZM521",
      "rendement": "4-6 tonnes/hectare",
      "cycle_vegetatif": "90-110 jours"
    }
  ]
}
```

---

## 📦 GESTION DES STOCKS

### CRÉER UN STOCK
**Endpoint:** `POST /stock/`  
**Auth Required:** ✅ Oui (Multiplicateur validé avec rôle approprié)

**Request:**
```json
{
  "category": "Base",
  "variety": 1,
  "qte_totale": 500.0,
  "prix_vente_unitaire": 15000,
  "date_expiration": "2024-12-31",
  "details": "En kilogrammes"
}
```

**Response (201):**
```json
{
  "id": 1,
  "category": "Base",
  "variety": 1,
  "qte_totale": 500.0,
  "qte_restante": 500.0,
  "prix_vente_unitaire": 15000,
  "date_expiration": "2024-12-31",
  "details": "En kilogrammes",
  "created_at": "2024-01-15T10:30:00Z",
  "validated_by": null,
  "validated_at": null,
  "created_by": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

### LISTE DES STOCKS
**Endpoint:** `GET /stock/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `variety__plant__name` : nom de la plante
- `variety__nom` : nom de la variété
- `created_at__gte` : date minimum (YYYY-MM-DD)
- `created_at__lte` : date maximum (YYYY-MM-DD)
- `created_by__multiplicator__province` : province
- `created_by__multiplicator__commune` : commune
- `created_by__username` : créateur
- `search` : recherche

**Response (200):**
```json
{
  "count": 10,
  "next": "?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "category": "Base",
      "variety": 1,
      "qte_totale": 500.0,
      "qte_restante": 450.0,
      "prix_vente_unitaire": 15000,
      "date_expiration": "2024-12-31",
      "validated_by": {
        "id": 1,
        "username": "admin"
      },
      "validated_at": "2024-01-16T09:00:00Z",
      "created_by": {
        "id": 5,
        "username": "john_doe"
      }
    }
  ]
}
```

### DÉTAIL D'UN STOCK
**Endpoint:** `GET /stock/{id}/`  
**Auth Required:** ✅ Oui

**Response (200):**
```json
{
  "id": 1,
  "category": "Base",
  "variety": 1,
  "qte_totale": 500.0,
  "qte_restante": 450.0,
  "prix_vente_unitaire": 15000,
  "date_expiration": "2024-12-31",
  "validated_by": {
    "id": 1,
    "username": "admin"
  },
  "validated_at": "2024-01-16T09:00:00Z"
}
```

### SUPPRIMER UN STOCK
**Endpoint:** `DELETE /stock/{id}/`  
**Auth Required:** ✅ Oui (Propriétaire ou Admin)

**Response (204):**
```
No Content
```

---

## 🛒 SYSTÈME DE COMMANDES

### CRÉER UNE COMMANDE
**Endpoint:** `POST /commande/`  
**Auth Required:** ✅ Oui

**Request:**
```json
{
  "stock": 1,
  "quantite": 50.0
}
```

**Response (201):**
```json
{
  "id": 1,
  "acheteur": {
    "id": 2,
    "user": {
      "id": 6,
      "username": "marie_cultivateur"
    },
    "types": "cultivateurs",
    "province": "Bururi",
    "is_validated": true
  },
  "stock": {
    "id": 1,
    "variety_info": {
      "id": 1,
      "nom": "Maïs Blanc Précoce",
      "plant": {
        "id": 1,
        "name": "Maïs"
      }
    },
    "created_by": {
      "id": 1,
      "user": {
        "id": 5,
        "username": "john_doe"
      },
      "type_multiplicator": "Certifiés"
    },
    "category": "Certifiés",
    "qte_restante": 450.0,
    "prix_vente_unitaire": 15000
  },
  "quantite": 50.0,
  "prix_unitaire": 15000,
  "montant_total": 750000,
  "montant_paye": 0,
  "is_delivered": false,
  "delivered_date": null,
  "created_at": "2024-01-15T11:00:00Z"
}
```


### LISTE DES COMMANDES
**Endpoint:** `GET /commande/`  
**Auth Required:** ✅ Oui

**Response (200):**
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "acheteur": {
        "id": 2,
        "user": {
          "username": "marie_cultivateur"
        }
      },
      "stock": {
        "id": 1,
        "variety_info": {
          "nom": "Maïs Blanc Précoce"
        },
        "category": "Certifiés",
        "prix_vente_unitaire": 15000
      },
      "quantite": 50.0,
      "montant_total": 750000,
      "is_delivered": false,
      "created_at": "2024-01-15T11:00:00Z"
    }
  ]
}
```

### MARQUER COMMANDE COMME LIVRÉE
**Endpoint:** `GET /commande/{id}/delivered/`  
**Auth Required:** ✅ Oui (Vendeur uniquement)

**Response (200):**
```json
{
  "status": "Commande livrée avec succès"
}
```

### ANNULER UNE COMMANDE
**Endpoint:** `DELETE /commande/{id}/`  
**Auth Required:** ✅ Oui

**Response (204):**
```json
{
  "status": "Commande annulée"
}
```

---

## ⭐ SYSTÈME D'ÉVALUATION

### AJOUTER UNE NOTE
**Endpoint:** `POST /note/`  
**Auth Required:** ✅ Oui (Acheteur de la commande livrée)

**Request:**
```json
{
  "stock": 1,
  "commande": 1,
  "etoiles": 5,
  "commentaire": "Excellente qualité, germination à 95%"
}
```

**Response (201):**
```json
{
  "id": 1,
  "stock": 1,
  "commande": 1,
  "etoiles": 5,
  "commentaire": "Excellente qualité, germination à 95%",
  "created_at": "2024-01-20T14:30:00Z",
  "created_by": 3
}
```

### LISTE DES NOTES
**Endpoint:** `GET /note/`  
**Auth Required:** ✅ Oui

**Response (200):**
```json
{
  "count": 10,
  "results": [
    {
      "id": 1,
      "stock": 1,
      "commande": 1,
      "etoiles": 5,
      "commentaire": "Excellente qualité",
      "created_at": "2024-01-20T14:30:00Z"
    }
  ]
}
```

---

## 📉 GESTION DES PERTES

### DÉCLARER UNE PERTE
**Endpoint:** `POST /perte/`  
**Auth Required:** ✅ Oui (Propriétaire du stock)

**Request:**
```json
{
  "stock": 1,
  "quantite": 25,
  "details": "Semences endommagées par l'humidité lors du stockage"
}
```

**Response (201):**
```json
{
  "id": 1,
  "stock": 1,
  "quantite": 25,
  "montant_perdu": 375000,
  "details": "Semences endommagées par l'humidité lors du stockage",
  "created_at": "2024-01-18T09:15:00Z",
  "created_by": 1
}
```

### LISTE DES PERTES
**Endpoint:** `GET /perte/`  
**Auth Required:** ✅ Oui

**Query Params:**
- `created_at__gte` : date minimum
- `created_at__lte` : date maximum

**Response (200):**
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "stock": 1,
      "quantite": 25,
      "montant_perdu": 375000,
      "details": "Semences endommagées par l'humidité",
      "created_at": "2024-01-18T09:15:00Z"
    }
  ]
}
```

### ANNULER UNE PERTE
**Endpoint:** `DELETE /perte/{id}/`  
**Auth Required:** ✅ Oui (Propriétaire)

**Response (204):**
```json
{
  "status": "Perte annulée et stock rétabli"
}
```

---

## 📋 RÈGLES MÉTIER

### HIÉRARCHIE DE DISTRIBUTION
```
Pré_Bases → Base → Certifiés → Cultivateurs
```

### RÈGLES DE COMMANDE

| Type Acheteur | Peut commander chez | Conditions |
|---------------|---------------------|------------|
| **Cultivateurs** | Certifiés seulement | Aucune restriction de variété |
| **Pré_Bases** | Pré_Bases seulement | Même variété uniquement |
| **Base** | Pré_Bases seulement | Variétés qu'il gère lui-même |
| **Certifiés** | Base seulement | Variétés qu'il gère lui-même |

### PERMISSIONS DE CRÉATION DE STOCK

| Rôle | Peut créer stocks de type |
|------|---------------------------|
| **Pré_Bases** | Pré_Bases, Base |
| **Base** | Base, Certifiés (si rôle validé) |
| **Certifiés** | Certifiés (si rôle validé) |

### WORKFLOW DE VALIDATION

1. **Inscription Multiplicateur** → En attente validation admin
2. **Validation Admin** → Compte activé
3. **Création Stock** → En attente validation admin
4. **Validation Stock** → Visible aux acheteurs
5. **Demande Nouveau Rôle** → En attente validation admin
6. **Validation Rôle** → Nouvelles permissions accordées

---

## 🔑 AUTHENTIFICATION JWT

### Headers requis pour les endpoints protégés:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Gestion du token expiré:
Si vous recevez une erreur 401, utilisez le refresh token:
```json
POST /refresh/
{
  "refresh": "votre_refresh_token"
}
```

---

## ⚠️ CODES D'ERREUR

| Code | Signification | Exemple |
|------|---------------|---------|
| **200** | Succès | Requête réussie |
| **201** | Créé | Ressource créée avec succès |
| **204** | Pas de contenu | Suppression réussie |
| **400** | Mauvaise requête | Données invalides |
| **401** | Non autorisé | Token manquant ou invalide |
| **403** | Interdit | Permissions insuffisantes |
| **404** | Non trouvé | Ressource inexistante |
| **500** | Erreur serveur | Erreur interne |

### Exemples de réponses d'erreur:

**400 - Validation Error:**
```json
{
  "status": "Document justificatif requis pour les multiplicateurs"
}
```

**403 - Permission Denied:**
```json
{
  "status": "Vous ne pouvez créer que des stocks de type : Base, Certifiés"
}
```

**400 - Business Rule Violation:**
```json
{
  "status": "Un cultivateur ne peut commander que chez un certifiés"
}
```

---

## 📝 NOTES IMPORTANTES

1. **Emails désactivés** : Les notifications par email sont temporairement désactivées en production
2. **Pagination** : Par défaut 20 éléments par page, utilisez `?page=2` pour la page suivante
3. **Filtres** : Combinez plusieurs filtres avec `&` : `?province=Gitega&is_validated=true`
4. **Upload de fichiers** : Utilisez `multipart/form-data` pour les documents et images
5. **Dates** : Format ISO 8601 : `2024-01-15T10:30:00Z`
6. **Cultivateurs** : Validation automatique à l'inscription, pas de document requis
7. **Multiplicateurs** : Doivent attendre validation admin avant de pouvoir se connecter

---

**Documentation générée le:** Février 2026  
**Contact Support:** support@assma.amidev.bi
