# BackEnd/database.py
from sqlmodel import SQLModel, create_engine, Session
from sqlalchemy.orm import sessionmaker
from typing import Generator
import os

# 1. Configuration de la connexion PostgreSQL via variables d'environnement
# Utilisez ces valeurs par défaut si vous avez lancé PostgreSQL via le docker-compose fourni :
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://konekte_user:Nap_lite@localhost:5432/konekte_db"
)

# L'option echo=True affiche les requêtes SQL dans la console (utile pour le debug)
engine = create_engine(DATABASE_URL, echo=False, pool_pre_ping=True)

# 2. Fonction pour créer les tables (utilisée par Alembic ou à l'initialisation)
def create_db_and_tables():
    """Crée les tables dans la base de données PostgreSQL si elles n'existent pas."""
    # Cette méthode n'est plus la méthode principale de création de tables avec Alembic,
    # mais elle peut être utilisée pour un setup initial ou des tests.
    SQLModel.metadata.create_all(engine)
    print("Tables created (or already existed).")


# 3. Dépendance pour les requêtes FastAPI
def get_session() -> Generator[Session, None, None]:
    """Dépendance FastAPI pour obtenir une session de base de données."""
    with Session(engine) as session:
        yield session

# Note: La fonction create_db_and_tables() est généralement appelée une seule fois
# avant que l'application ne démarre ses migrations.
