from sqlmodel import SQLModel, create_engine
import models # Importez vos modèles

sqlite_file = "database.db"
engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

def init_db():
    print("Création de la base de données et des tables...")
    SQLModel.metadata.create_all(engine)
    print("Terminé.")

if __name__ == "__main__":
    init_db()
