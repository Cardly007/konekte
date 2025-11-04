# Konekte App - Instructions de Configuration

Bienvenue sur Konekte ! Ce guide vous expliquera comment configurer et lancer l'application en local pour le développement.

L'application est composée de deux parties principales :
1.  **Backend** : Une API FastAPI en Python.
2.  **Frontend** : Une application mobile développée avec Flutter.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants sur votre machine :

-   **Flutter** : [Instructions d'installation](https://flutter.dev/docs/get-started/install)
-   **Python** (version 3.9 ou supérieure)
-   **Docker** et **Docker Compose** : [Instructions d'installation](https://docs.docker.com/get-docker/)

## 🚀 Lancement de l'Application

Suivez ces étapes dans l'ordre pour lancer l'environnement de développement complet.

### Étape 1 : Configurer le Backend

Le backend nécessite une base de données PostgreSQL et des clés d'API pour les services externes (comme Cloudinary).

#### 1.1. Lancer la Base de Données avec Docker

Le moyen le plus simple de démarrer une base de données PostgreSQL est d'utiliser le fichier `docker-compose.yml` fourni.

```bash
# Naviguez dans le dossier du backend
cd BackEnd

# Lancez le conteneur Docker en arrière-plan
docker-compose up -d
```

Cette commande va télécharger l'image de PostgreSQL et démarrer un conteneur avec la base de données `konekte_db` pré-configurée.

#### 1.2. Créer le Fichier d'Environnement

Le backend utilise un fichier `.env` pour gérer les secrets. Créez ce fichier à la racine du dossier `BackEnd`.

```bash
# Toujours dans le dossier BackEnd, créez le fichier .env
touch .env
```

Ouvrez ce fichier `.env` et ajoutez les variables suivantes. **Remplacez les valeurs de Cloudinary par vos propres clés.**

```dotenv
# BackEnd/.env

# Clé secrète pour les tokens JWT (peut être n'importe quelle chaîne complexe)
SECRET_KEY="votre_super_cle_secrete_ici"

# URL de la base de données (correspond au docker-compose.yml)
DATABASE_URL="postgresql://konekte_user:Nap_lite@localhost:5432/konekte_db"

# Clés pour le service d'upload d'images Cloudinary
CLOUDINARY_CLOUD_NAME="votre_cloud_name"
CLOUDINARY_API_KEY="votre_api_key"
CLOUDINARY_API_SECRET="votre_api_secret"
```

#### 1.3. Installer les Dépendances et Lancer le Serveur

```bash
# (Optionnel mais recommandé) Créez un environnement virtuel
python -m venv venv
source venv/bin/activate  # Sur Windows : venv\Scripts\activate

# Installez les dépendances Python
pip install -r requirements.txt

# Depuis la racine du projet (le dossier au-dessus de BackEnd), lancez le serveur FastAPI
uvicorn BackEnd.app:app --host 0.0.0.0 --port 8000 --reload
```

Le serveur backend est maintenant en cours d'exécution et accessible à `http://localhost:8000`.

### Étape 2 : Lancer l'Application Frontend (Flutter)

1.  **Ouvrez un nouveau terminal** et placez-vous à la racine du projet (là où se trouve `pubspec.yaml`).

2.  **Installez les dépendances Flutter** :
    ```bash
    flutter pub get
    ```

3.  **Lancez l'application** sur un émulateur ou un appareil physique :
    ```bash
    flutter run
    ```

L'application devrait maintenant se lancer et être capable de communiquer avec votre backend local.

---

## ✅ Vérification

-   Le serveur backend doit afficher des logs dans son terminal sans erreur.
-   L'application Flutter doit se lancer sans erreur de compilation.
-   Vous devriez être capable de créer un compte et de vous connecter.

Si vous rencontrez des problèmes, vérifiez que Docker est bien en cours d'exécution et que les variables dans votre fichier `.env` sont correctes.
