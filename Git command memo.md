# Git Command Memo

# Initialiser un dépôt
git init

# Lier à un dépôt distant
git remote add origin https://github.com/ton-pseudo/ton-repo.git

# Vérifier l'état
git status

# Ajouter des fichiers
git add .                # Ajouter tous les fichiers
# ou
git add fichier.dart     # Ajouter un fichier spécifique

# Commit
git commit -m "Message clair"

# Push vers GitHub
git push                 # Push vers la branche suivie
# ou pour la première fois
git push -u origin main

# Pull (récupérer les modifications distantes)
git pull

# Créer une nouvelle branche
git checkout -b nom-de-ta-branche

# Changer de branche
git checkout main

git checkout develop

# Fusionner une branche dans une autre
git checkout develop
git merge feature/ma-feature

# Supprimer une branche
git branch -d ma-branche              # Supprimer localement
git push origin --delete ma-branche  # Supprimer à distance

# Voir les branches
git branch        # Locales
git branch -r     # Distantes
git branch -a     # Toutes

# Voir l'historique des commits
git log --oneline

# Mettre à jour une branche depuis une autre
git checkout develop
git pull origin main

# Cloner un projet
git clone https://github.com/ton-pseudo/ton-repo.git
