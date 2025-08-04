from sqlmodel import SQLModel, create_engine

sqlite_file = "database.db"
engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

def init_db():
    SQLModel.metadata.create_all(engine)
