# Guide de Test - Phase 1 (Partie 1) : Auth & Profil

Ce document a pour but de valider les fonctionnalités d'authentification et de gestion de profil développées dans la première partie de la Phase 1.

**Prérequis :**
- L'infrastructure de la Phase 0 doit être fonctionnelle (serveur FastAPI, base de données, etc.).
- Le serveur FastAPI doit être en cours d'exécution.
- Il est recommandé de partir d'une base de données vide pour ces tests. Vous pouvez recréer les conteneurs Docker pour cela (`docker-compose -f BackEnd/docker-compose.yml down && docker-compose -f BackEnd/docker-compose.yml up -d`).

**Outils :**
- Un terminal avec `curl` installé.
- `jq` (optionnel, pour formater les réponses JSON et les rendre plus lisibles).

---

## Étape 1 : Inscription d'un Nouvel Utilisateur

Cette étape valide la création d'un nouveau compte.

1.  **Exécutez la commande `curl` suivante** pour créer un nouvel utilisateur. Remplacez les valeurs si vous le souhaitez.
    ```bash
    curl -X POST "http://localhost:8000/api/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test.user@example.com",
      "password": "a-secure-password",
      "first_name": "Test",
      "date_of_birth": "1995-05-10",
      "gender": "woman"
    }' | jq
    ```

2.  **Résultat Attendu :**
    La réponse doit être un statut `201 Created` et contenir un token JWT.
    ```json
    {
      "access_token": "eyJhbGciOiJI...",
      "token_type": "bearer"
    }
    ```
    - **Notez ce token**, nous l'appellerons `ACCESS_TOKEN` pour la suite des tests.

3.  **Test d'Erreur (Email déjà utilisé) :**
    Relancez exactement la même commande.
    - **Résultat Attendu :** Une erreur `409 Conflict` avec un message indiquant que l'email existe déjà.
    ```json
    {
      "detail": "An account with this email already exists."
    }
    ```

---

## Étape 2 : Connexion de l'Utilisateur

Cette étape valide le processus de connexion.

1.  **Exécutez la commande `curl` suivante** avec les mêmes identifiants que ceux utilisés pour l'inscription.
    ```bash
    curl -X POST "http://localhost:8000/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test.user@example.com",
      "password": "a-secure-password"
    }' | jq
    ```

2.  **Résultat Attendu :**
    Un statut `200 OK` et un nouveau token JWT.
    ```json
    {
      "access_token": "eyJhbGciOiJI...",
      "token_type": "bearer"
    }
    ```

3.  **Test d'Erreur (Mauvais mot de passe) :**
    - **Résultat Attendu :** Une erreur `401 Unauthorized`.

---

## Étape 3 : Accéder au Profil (Authentifié)

Cette étape valide la protection des routes et la récupération du profil.

1.  **Exportez le token** dans une variable d'environnement pour plus de facilité.
    ```bash
    export ACCESS_TOKEN="collez_votre_token_ici"
    ```

2.  **Exécutez la commande `curl` suivante** pour récupérer le profil.
    ```bash
    curl -X GET "http://localhost:8000/api/v1/profiles/me" \
    -H "Authorization: Bearer $ACCESS_TOKEN" | jq
    ```

3.  **Résultat Attendu :**
    Un statut `200 OK` avec les informations du profil créé lors de l'inscription.
    ```json
    {
      "first_name": "Test",
      "date_of_birth": "1995-05-10",
      "gender": "woman",
      "bio": null,
      "height": null,
      "occupation": null,
      "education": null,
      "id": "...",
      "user_id": "...",
      "photos": []
    }
    ```

---

## Étape 4 : Mettre à Jour le Profil

Cette étape valide la mise à jour des informations du profil.

1.  **Exécutez la commande `curl` suivante** pour ajouter une biographie et une profession.
    ```bash
    curl -X PUT "http://localhost:8000/api/v1/profiles/me" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "first_name": "Test",
      "date_of_birth": "1995-05-10",
      "gender": "woman",
      "bio": "Ceci est ma nouvelle biographie.",
      "occupation": "Ingénieur Logiciel"
    }' | jq
    ```

2.  **Résultat Attendu :**
    Un statut `200 OK` avec le profil mis à jour.
    ```json
    {
      "first_name": "Test",
      ...
      "bio": "Ceci est ma nouvelle biographie.",
      "occupation": "Ingénieur Logiciel",
      ...
    }
    ```

3.  **Vérification :**
    Relancez la commande de l'Étape 3 (`GET /profiles/me`) pour confirmer que les modifications ont bien été sauvegardées.

---

Si toutes ces étapes sont validées, l'API d'authentification et de gestion de profil est considérée comme **fonctionnelle**.
