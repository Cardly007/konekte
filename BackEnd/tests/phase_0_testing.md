# Guide de Test - Phase 0 : Infrastructure

Ce document a pour but de valider que toute l'infrastructure backend mise en place lors de la Phase 0 est correctement configurée et fonctionnelle.

**Prérequis :**
- Vous devez avoir suivi les étapes 1 à 3 du `BackEnd/README.md` (installation des dépendances, configuration du `.env`, et lancement des services Docker).
- Docker doit être en cours d'exécution.

---

## Étape 1 : Vérifier les Services Docker

Cette étape confirme que la base de données PostgreSQL et le cache Redis sont bien en cours d'exécution.

1.  **Exécutez la commande suivante** depuis la racine du projet :
    ```bash
    docker ps
    ```

2.  **Résultat Attendu :**
    Vous devriez voir deux conteneurs listés, avec le statut `Up` :
    - `konekte-backend-db-1` (ou similaire) pour PostgreSQL.
    - `konekte-backend-cache-1` (ou similaire) pour Redis.

    Si les conteneurs ne sont pas en cours d'exécution, relancez la commande : `docker-compose -f BackEnd/docker-compose.yml up -d`.

---

## Étape 2 : Vérifier le Lancement du Serveur FastAPI

Cette étape valide que le serveur web démarre correctement.

1.  **Exécutez la commande de lancement** depuis la racine du projet :
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
    ```

2.  **Résultat Attendu :**
    Le terminal devrait afficher des logs indiquant que le serveur a démarré avec succès. Les dernières lignes devraient ressembler à ceci :
    ```
    INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
    INFO:     Started reloader process [...]
    ```

3.  **Validation via le navigateur ou `curl` :**
    Ouvrez votre navigateur à l'adresse `http://localhost:8000` ou exécutez la commande suivante dans un autre terminal :
    ```bash
    curl http://localhost:8000
    ```

4.  **Résultat Attendu :**
    La page web ou la console devrait afficher la réponse JSON suivante, confirmant que l'API est en ligne :
    ```json
    {
      "status": "ok",
      "message": "Welcome to the Konekte API"
    }
    ```

---

## Étape 3 : Vérifier le Seeding de la Base de Données

Cette étape valide que le script de peuplement de la base de données fonctionne et que les données sont correctement insérées.

1.  **Exécutez le script de seeding** depuis la racine du projet :
    ```bash
    python -m BackEnd.seed_data
    ```

2.  **Résultat Attendu :**
    Le script affichera des logs indiquant la progression. La sortie finale devrait ressembler à :
    ```
    INFO:__main__:Starting database seeding...
    INFO:__main__:Created 50 users with profiles and photos.
    INFO:__main__:Created [...] interactions.
    INFO:__main__:Created [...] matches.
    INFO:__main__:Database seeding completed successfully!
    ```
    *Note : Si vous relancez le script, il devrait simplement afficher : `INFO:__main__:Database already seeded. Exiting.`*

---

## Étape 4 : Vérifier les Données en Base

Cette étape finale confirme que les données ont bien été écrites dans la base de données PostgreSQL.

1.  **Connectez-vous au conteneur PostgreSQL.** Vous pouvez utiliser l'interface graphique de Docker ou la ligne de commande suivante :
    ```bash
    docker exec -it konekte-backend-db-1 psql -U user -d konekte
    ```
    - `konekte-backend-db-1` est le nom du conteneur (vérifiez avec `docker ps`).
    - `user` est le nom d'utilisateur et `konekte` le nom de la base de données, définis dans `docker-compose.yml`.

2.  **Exécutez une requête SQL** pour compter le nombre d'utilisateurs. Une fois dans l'interface `psql`, tapez :
    ```sql
    SELECT COUNT(*) FROM users;
    ```

3.  **Résultat Attendu :**
    La console devrait retourner `50`, confirmant que les 50 utilisateurs de test ont bien été créés.
    ```
     count
    -------
        50
    (1 row)
    ```

4.  **Quittez `psql`** en tapant `\q` et en appuyant sur Entrée.

---

Si toutes ces étapes sont validées avec succès, l'infrastructure de la Phase 0 est considérée comme **stable et prête** pour le développement de la Phase 1.
