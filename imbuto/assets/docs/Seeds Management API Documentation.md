# Table des matières 

[**Chapitre I :  Vue d'ensemble de l'application	2**](#chapitre-i-:-vue-d'ensemble-de-l'application)

[**Chapitre II : Système d'Authentification	3**](#chapitre-ii-:-système-d'authentification)

[**Chapitre III: Inscription des Utilisateurs	5**](#chapitre-iii:-inscription-des-utilisateurs)

[**Chapitre IV : Gestion des Rôles Multiples	7**](#chapitre-iv-:-gestion-des-rôles-multiples)

[**Chapitre V : Gestion du Catalogue(Plantes et Variétés)	9**](#chapitre-v-:-gestion-du-catalogue)

[**Chapitre VI : Gestion des Stocks	11**](#chapitre-vi-:-gestion-des-et-stocks)

[**Chapitre VII : Système de Commandes	13**](#chapitre-vii-:-système-de-commandes)

[**Chapitre VIII : Système d'Évaluation	16**](#chapitre-viii-:-système-d'évaluation)

[**Chapitre IX : Gestion des Pertes**](#chapitre-ix-:-gestion-des-pertes)	**[18](#heading=h.qcu35yfppari)**

[**Chapitre XI : Processus de Validation (Pour les Superusers)**](#chapitre-xi-:-processus-de-validation-\(pour-les-superusers\))	**[20](#heading=h.hchh3p4k9rqz)**

[**XIII : Conclusion et Flux Utilisateurs**](#xiii-:-conclusion)

	[**21**](#xiii-:-conclusion)

# 

# Documentation Complète \- API Système de Gestion des Semences

# Chapitre I :  Vue d'ensemble de l'application {#chapitre-i-:-vue-d'ensemble-de-l'application}

Cette API gère un système de multiplication et distribution de semences au Burundi avec une hiérarchie stricte :

- Pré Bases : Producteurs de semences de base ,  
-  Base : Transforment les Pré Bases en semences Base,  
-  Certifiés : Transforment les Base en semences Certifiées,  
- Cultivateurs : Achètent les semences Certifiées pour la production,

# Chapitre II : Système d'Authentification {#chapitre-ii-:-système-d'authentification}

Types d'utilisateurs dans le système :

1. Superuser (Administrateur) : Valide tout, accès complet  
2. Multiplicateurs : Pré Bases, Base, ou Certifiés (doivent être validés)  
3. Cultivateurs : Achètent des semences certifiées  
* Connexion \- POST \`/login/\`  
  - Pour un Multiplicateur :

      \`\`\`json

    {

      "username": "john\_doe",

      "password": "motdepasse123",

    }

    \`\`\`

  - Pour un Cultivateur :

                          \`\`\`json  
{  
  "username": "marie\_cultivatrice",   
  "password": "motdepasse123",  
  "user\_type": "cultivateurs"  
}  
\`\`\`

- Réponse réussie (Multiplicateur) :

  \`\`\`json

  {

    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",

    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",

    "user": {

      "id": 1,

      "username": "john\_doe",

      "email": "john@example.com",

      "first\_name": "John",

      "last\_name": "Doe"

    },

    "multiplicator": {

      "id": 1,

      "types": "multiplicateurs",

      "type\_multiplicator": "Base",

      "province": "Bujumbura Mairie",

      "commune": "Mukaza",

      "colline": "Rohero",

      "phone\_number": "+25779123456",

      "other\_phone\_number": "+25779654321",

      "is\_validated": true,

      "document\_justificatif": "/media/documents\_multiplicateurs/doc.pdf",

      "created\_at": "2024-01-15T10:30:00Z",

      "all\_roles": \["Base", "Pré\_Bases"\]

    }

  }


  \`\`\`


 Changement de mot de passe \- POST \`/user/{id}/changepassword/\`

\*\*Prérequis\*\* : Être authentifié

\`\`\`json  
{  
  "old\_password": "ancien\_mot\_de\_passe",  
  "new\_password": "nouveau\_mot\_de\_passe"  
}  
\`\`\`

\#\#\# Réinitialisation de mot de passe  
\*\*Note\*\* : Fonctionnalité temporairement désactivée (problème SMTP en production)

# Chapitre III: Inscription des Utilisateurs {#chapitre-iii:-inscription-des-utilisateurs}

*   Inscription d'un Multiplicateur \- POST \`/Multiplicator/\`

\!\!\! Important : Cette inscription se fait SANS authentification (utilisateur anonyme)  
\`\`\`json  
{  
  "user": {  
    "username": "nouveau\_multiplicateur",  
    "email": "nouveau@example.com",   
    "first\_name": "Jean",  
    "last\_name": "Dupont",  
    "password": "motdepasse123"  
  },  
  "type\_multiplicator": "Base",  
  "province": "Gitega",  
  "commune": "Gitega",  
  "colline": "Mushasha",  
  "phone\_number": "+25779123456",  
  "other\_phone\_number": "+25779654321",  
  "types": "multiplicateurs",  
  "document\_justificatif": "fichier\_PDF\_ou\_image"  
}  
\`\`\`

- Ce qui se passe après l'inscription :  
  *  Compte créé avec \`is\_validated \= false\`  
    *  Email automatique envoyé aux superusers  
    *  Multiplicateur doit attendre la validation  
    *  Ne peut pas se connecter tant qu'il n'est pas validé  
    


*  Inscription d'un Cultivateur \- POST \`/Multiplicator/\`  
  \`\`\`json  
  {  
    "user": {  
      "username": "cultivateur\_marie",  
      "email": "marie@example.com",  
      "first\_name": "Marie",  
      "last\_name": "Nzeyimana",   
      "password": "motdepasse123"  
    },  
    "province": "Bururi",  
    "commune": "Bururi",  
    "colline": "Kiganda",  
    "phone\_number": "+25779987654",  
    "types": "cultivateurs"  
  }  
  \`\`\`

  - Différences pour les cultivateurs :  
    * Pas de document justificatif requis  
    * Activation automatique (\`is\_active \= true\`)  
    * Peut se connecter immédiatement  
    * Pas de \`type\_multiplicator\`

# Chapitre IV : Gestion des Rôles Multiples {#chapitre-iv-:-gestion-des-rôles-multiples}

* Pourquoi des rôles multiples ?

Un multiplicateur peut évoluer et obtenir plusieurs certifications. Par exemple :

- Commencer comme Base  
  - Obtenir plus tard la certification Pré Bases  
  - Ou obtenir la certification Certifiés

* Ajouter un nouveau rôle \- POST \`/Multiplicator\_Roles/\`

 Prérequis : Être connecté comme multiplicateur validé

\`\`\`json  
{  
  "type\_multiplicator": "Pré\_Bases",  
  "document": "certificat\_pre\_bases.pdf"  
}  
\`\`\`

- Ce qui se passe :  
  * Rôle créé avec \`is\_validated \= false\`  
    * Email automatique aux superusers  
    * Attente de validation par un superuser  
    *  Ne peut pas utiliser ce nouveau rôle tant qu'il n'est pas validé

*  Consulter ses rôles \- GET \`/Multiplicator\_Roles/\`  
  - Réponse :  
    \`\`\`json  
    {  
      "count": 2,  
      "results": \[  
        {  
          "id": 1,  
          "type\_multiplicator": "Base",  
          "is\_validated": true,  
          "validated\_at": "2024-01-10T14:30:00Z",  
          "validated\_by": "admin",  
          "document": "/media/docs\_roles/cert\_base.pdf",  
          "created\_at": "2024-01-01T10:00:00Z"  
        },  
        {  
          "id": 2,   
          "type\_multiplicator": "Pré\_Bases",  
          "is\_validated": false,  
          "validated\_at": null,  
          "validated\_by": null,  
          "document": "/media/docs\_roles/cert\_pre\_bases.pdf",  
          "created\_at": "2024-01-15T16:20:00Z"  
        }  
      \]  
    }  
    \`\`\`

# Chapitre V : Gestion du Catalogue {#chapitre-v-:-gestion-du-catalogue}

1. Plantes \- \`/plantes/\`

* Créer une plante \- POST (Multiplicateurs validés seulement)  
  \`\`\`json  
  {  
    "name": "Maïs"  
  }  
  \`\`\`

    
* Lister \- GET  
  \`\`\`json  
  {  
    "count": 3,  
    "results": \[  
      {  
        "id": 1,  
        "name": "Maïs",  
        "created\_at": "2024-01-01T10:00:00Z",  
        "created\_by": "admin"  
      }  
    \]  
  }  
  \`\`\`

2\. Variétés \- \`/variete/\`

* Créer une variété \- POST  
  \`\`\`json  
  {  
    "plant": 1,  
    "nom\_botanique": "Zea mays L.",  
    "nom": "Maïs Blanc Précoce",  
    "nom\_variete": "ZM521",  
    "type\_varietal": "Variété améliorée",  
    "nom\_kirundi": "Ibigori byera",  
    "code\_origine": "ZM521-BDI",  
    "centre\_origine": "ISABU \- Gitega",  
    "obtenteur": "Institut des Sciences Agronomiques du Burundi",  
    "mainteneur": "ISABU",  
    "annee\_diffusion": 2020,  
    "date\_inscription": "2020-03-15",  
    "numero\_enregistrement": "VAR-2020-001",  
    "service\_examen": "Service National des Semences",  
    "station\_examen": "Station de Gitega",  
    "periode\_examen": "2018-2020",  
    "zone\_culture": "Toutes les zones agro-écologiques",  
    "rendement": "4-6 tonnes/hectare",  
    "cycle\_vegetatif": "90-110 jours"  
  }

\`\`\`

# Chapitre VI : Gestion des et Stocks {#chapitre-vi-:-gestion-des-et-stocks}

1.  Créer une semence \- POST \`/semences/\`( Être multiplicateur validé,Avoir le rôle correspondant à la catégorie)  
* Rè\`\`\`json

  {

    "category": "Base",

    "variety": 1,

    "details": "Vendu par sac de 25kg",

    "photo": "fichier\_image.jpg"

  }

  \`\`\`

2. Ajouter un stock \- POST \`/stock/\`  
*  Prérequis :  
  - Être multiplicateur validé  
  - Avoir le rôle correspondant à la catégorie  
* Regles importantes :  
  -  Pré\_Bases peut créer : Pré\_Bases, Base  
  - Base peut créer : Base,Certifiés selon les rôles qu’il a  
  -  Certifiés peut créer : Certifiés selon les rôles qu’il a 

    \`\`\`json

    {

      "seed": 1,

      "qte\_totale": 500.0,

      "prix\_vente\_unitaire": 15000,

      "date\_expiration": "2024-12-31"

    }

    \`\`\`

    

* Ce qui se passe :  
  -  Stock créé avec \`validated\_by \= null\`  
  -  Email automatique aux superusers  
  -  Stock invisible aux acheteurs tant qu'il n'est pas validé  
  -  \`qte\_restante\` \= \`qte\_totale\` automatiquement  
* Réponse :

  \`\`\`json

  {

    "id": 1,

    "category": "Base",

    "variety": {

      "id": 1,

      "nom": "Maïs Blanc Précoce",

      "plant": {

        "id": 1,

        "name": "Maïs"

      }

    },

    "qte\_totale": 500.0,

    "qte\_restante": 500.0,

    "prix\_vente\_unitaire": 15000,

    "date\_expiration": "2024-12-31",

    "is\_validated": false,

    "created\_at": "2024-01-15T10:30:00Z",

    "validated\_by": null,

    "validated\_at": null,

    "created\_by": {

      "id": 1,

      "username": "john\_doe"

    }

  }


  \`\`\`

# Chapitre VII : Système de Commandes {#chapitre-vii-:-système-de-commandes}

*  Règles métier strictes :

| Type Acheteur | Peut commander chez | Conditions |
| :---- | :---- | :---- |
| Cultivateurs | Certifiés seulement | Aucune restriction de variété |
| Pré Bases | Pré Bases seulement | Même variété uniquement  |
| Base | Pré Bases seulement  | Variétés qu'il gère lui-même |
| Certifiés | Base seulement | Variétés qu'il gère lui-même |

* Créer une commande \- POST \`/commande/\`  
    

  \`\`\`json  
  {  
    "stock": 1,  
    "quantite": 50.0  
  }  
  \`\`\`  
* Vérifications automatiques :  
  - Stock validé par un superuser ?  
  -  Quantité disponible suffisante ?  
  -  Respect des règles métier ?  
  -  Variété autorisée pour ce type d'acheteur ?  
* Réponse réussie :  
      \`\`\`json

  {  
    "id": 1,  
    "acheteur": "john\_doe",  
    "stock": {  
      "id": 1,  
      "seed": {  
        "category": "Base",  
        "variety": {  
          "nom": "Maïs Blanc Précoce"  
        }  
      },  
      "prix\_vente\_unitaire": 15000  
    },  
    "quantite": 50.0,  
    "prix\_unitaire": 15000,  
    "montant\_total": 750000,  
    "montant\_paye": 0,  
    "is\_delivered": false,  
    "created\_at": "2024-01-15T11:00:00Z"  
  }  
  \`\`\`  
    
    
    
  - Effets automatiques :  
    *  \`stock.qte\_restante\` réduite de 50  
    * Si stock épuisé, plus disponible pour commande  
    *   
* Annuler une commande \- DELETE \`/commande/{id}/\`  
  - Effets :  
    *  Commande marquée \`is\_deleted \= true\`  
    * Stock remis automatiquement

# 

# 

# 

# 

# 

# 

#                        

# Chapitre VIII : Système d'Évaluation {#chapitre-viii-:-système-d'évaluation}

*  Ajouter une note \- POST \`/note/\`  
  - Conditions :  
    * Commande doit être livrée (\`is\_delivered \= true\`)  
    *  Seul l'acheteur peut noter sa commande


      \`\`\`json

      {

        "stock": 1,

        "commande": 1,

        "etoiles": 5,

        "commentaire": "Excellente qualité, germination à 95%"

      }

      

      \`\`\`

  - Réponse :

    \`\`\`json

    

    {

      "id": 1,

      "stock": {

        "id": 1,

        "category": "Certifiés",

        "variety": {

          "nom": "Maïs Blanc Précoce"

        }

      },

      "commande": 1,

      "etoiles": 5,

      "commentaire": "Excellente qualité, germination à 95%",

      "created\_at": "2024-01-20T14:30:00Z",

      "created\_by": {

        "id": 3,

        "username": "cultivateur\_marie"

      }

    }

    

    \`\`\`

# Chapitre IX : Gestion des Pertes {#chapitre-ix-:-gestion-des-pertes}

*  Déclarer une perte \- POST \`/perte/\`  
  - Conditions :  
    *  Stock doit être validé  
    * Quantité positive  
    * Ne pas dépasser le stock disponible

       			\`\`\`json  
{  
  "stock": 1,  
  "quantite": 25,  
  "details": "Semences endommagées par l'humidité lors du stockage"  
}  
\`\`\`

-  Calculs automatiques :  
  * \`montant\_perdu\` \= \`quantite\` × \`prix\_vente\_unitaire\`  
    *  \`stock.qte\_restante\` réduite automatiquement  
  - Réponse :

    \`\`\`json

    {

      "id": 1,

      "stock": {

        "seed": {

          "category": "Base",

          "variety": "Maïs Blanc Précoce"

        }

      },

      "quantite": 25,

      "montant\_perdu": 375000,

      "details": "Semences endommagées par l'humidité lors du stockage",

      "created\_at": "2024-01-18T09:15:00Z"

    }

    \`\`\`

# Chapitre XI : Processus de Validation (Pour les Superusers) {#chapitre-xi-:-processus-de-validation-(pour-les-superusers)}

*  Validation d'un Multiplicateur  
  - Interface Admin Django :  
    * Cocher \`is\_validated \= True\`  
    *  Remplir \`validated\_at\` automatiquement  
    * Optionnel : \`validation\_reason\` si refus

*  Validation d'un Rôle  
  - Interface Admin Django :  
    * Cocher \`is\_validated \= True\`   
    * Définir \`validated\_by\` automatiquement  
    * Remplir \`validated\_at\` automatiquement

*  Validation d'un Stock  
  - Interface Admin Django :  
    * Définir \`validated\_by\` (superuser)  
    * Remplir \`validated\_at\` automatiquement  
    * Stock devient visible aux acheteurs

    ttttttttttttttttttttttttttttttttttttttttttttt

# XIII : Conclusion {#xiii-:-conclusion}

 Flux Utilisateur Typiques

*  Nouveau Multiplicateur :  
  -   Inscription avec documents → Statut "En attente"  
  -  Attente validation admin → Email de confirmation  
  -  Validation → Peut se connecter  
  -  Création de semences → Selon ses rôles  
  -  Ajout de stocks → En attente validation  
  - Validation stock → Visible aux acheteurs  
* Cultivateur :  
  -  Inscription simple → Validation automatique    
  - Connexion immédiate  
  -  Commandes chez les Certifiés uniquement  
  -  Évaluation après livraison  
* Évolution d'un Multiplicateur :  
  - Demande nouveau rôle avec certificat  
  - Attente validation admin  
  - Validation → Nouvelles permissions  
  - Création de nouvelles catégories de semences

