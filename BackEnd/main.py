# from fastapi import FastAPI
# from pydantic import BaseModel
# from fastapi.middleware.cors import CORSMiddleware

# from models import User, Interaction

# app = FastAPI()

# # Base de données fictive de profils
# profils = {
#     1: {"nom": "Alice", "age": 25, "interets": ["sport", "voyage"]},
#     2: {"nom": "Bob", "age": 30, "interets": ["cinema", "lecture"]},
#     3: {"nom": "Charlie", "age": 28, "interets": ["voyage", "musique"]},
#     4: {"nom": "Diana", "age": 26, "interets": ["sport", "cuisine"]},
#     5: {"nom": "Ethan", "age": 32, "interets": ["musique", "sport"]},
# }



# # --------------------------
# # Initialisation DB
# # --------------------------
# sqlite_file = "database.db"
# engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

# def init_db():
#     SQLModel.metadata.create_all(engine)

# init_db()



# # Requête que Flutter va envoyer
# class RecommandationRequest(BaseModel):
#     user_id: int

# # Simuler un algorithme de recommandation très simple
# def recommander(user_id):
#     user = profils.get(user_id)
#     if not user:
#         return []
    
#     # Trouver les autres profils avec au moins un intérêt commun
#     recommandations = []
#     for pid, profil in profils.items():
#         if pid != user_id:
#             if any(interet in user['interets'] for interet in profil['interets']):
#                 recommandations.append(profil)
#     return recommandations




# # --------------------------
# # Création de l'app FastAPI
# # --------------------------





# # L'API que Flutter va appeler
# @app.post("/recommandation")
# def get_recommandations(request: RecommandationRequest):
#     recommandations = recommander(request.user_id)
#     return {"recommandations": recommandations}


# # Permet à ton app Flutter (sur mobile) d'accéder à l'API
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # en production, tu limiteras les origines
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# @app.get("/api/profils")
# async def get_profils():
#     return [
#         {
#             "id": 1,
#             "nom": "Alice",
#             "age": 25,
#             "description": "J'adore le sport et les voyages",
#             "image": "https://randomuser.me/api/portraits/women/65.jpg"
#         },
#         {
#             "id": 2,
#             "nom": "Bob",
#             "age": 30,
#             "description": "Passionné de cinéma et lecture",
#             "image": "https://randomuser.me/api/portraits/men/43.jpg"
#         },
#         {
#             "id": 3,
#             "nom": "Charlie",
#             "age": 28,
#             "description": "Fan de musique et voyages",
#             "image": "https://randomuser.me/api/portraits/men/52.jpg"
#         },
#     ]

# # Stockage des interactions par utilisateur
# interactions = {}

# # Modèle pour recevoir les likes
# class Interaction(BaseModel):
#     user_id: str  # identifiant de l'utilisateur qui swipe
#     profil_id: int
#     action: str  # 'like', 'dislike', 'superlike'

# # Endpoint pour obtenir les profils à swiper
# @app.get("/api/profils")
# async def get_profils():
#     return profils

# # Endpoint pour enregistrer une interaction
# @app.post("/api/interact")
# async def post_interaction(interaction: Interaction):
#     user = interaction.user_id
#     if user not in interactions:
#         interactions[user] = []

#     interactions[user].append({
#         "profil_id": interaction.profil_id,
#         "action": interaction.action
#     })

#     return {"status": "ok"}

# # Endpoint pour obtenir les stats d'un utilisateur
# @app.get("/api/stats/{user_id}")
# async def get_stats(user_id: str):
#     if user_id not in interactions:
#         return {"likes": 0, "dislikes": 0, "superlikes": 0}

#     user_interactions = interactions[user_id]
#     stats = {"likes": 0, "dislikes": 0, "superlikes": 0}
#     for inter in user_interactions:
#         if inter["action"] == "like":
#             stats["likes"] += 1
#         elif inter["action"] == "dislike":
#             stats["dislikes"] += 1
#         elif inter["action"] == "superlike":
#             stats["superlikes"] += 1
#     return stats

# @app.post("/api/reset")
# async def reset_interactions():
#     # interactions[1].clear()  # Vide les interactions de l'utilisateur 1
#     interactions.clear()  # Vide toutes les interactions
#     return {"status": "Tous les compteurs ont été remis à zéro."}

# # Exemple de route pour ajouter un utilisateur
# @app.post("/api/users")
# def create_user(user: User):
#     with Session(engine) as session:
#         session.add(user)
#         session.commit()
#         session.refresh(user)
#         return user

# # Exemple pour ajouter une interaction
# @app.post("/api/interact")
# def add_interaction(inter: Interaction):
#     with Session(engine) as session:
#         session.add(inter)
#         session.commit()
#         session.refresh(inter)
#         return inter



# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from sqlmodel import SQLModel, Session, create_engine, select
# from passlib.hash import bcrypt
# from fastapi import HTTPException
# from models import User, Interaction
# from jose import JWTError, jwt
# from datetime import datetime, timedelta
# from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

# from fastapi import Depends



# # Clé secrète pour signer les tokens JWT
# SECRET_KEY = "supersecretkey"
# ALGORITHM = "HS256"
# ACCESS_TOKEN_EXPIRE_MINUTES = 60

# oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/token")

# def create_access_token(data: dict, expires_delta: timedelta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)):
#     to_encode = data.copy()
#     expire = datetime.utcnow() + expires_delta
#     to_encode.update({"exp": expire})
#     return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# def verify_token(token: str):
#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
#         return payload.get("sub")
#     except JWTError:
#         return None




# app = FastAPI()

# # Autoriser les requêtes depuis Flutter
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Autorise toutes les origines
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Configuration base de données SQLite
# sqlite_file = "database.db"
# engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

# def init_db():
#     SQLModel.metadata.create_all(engine)

# init_db()

# # ------------------ ROUTES ------------------

# # POST - Enregistrer un nouvel utilisateur
# @app.post("/api/register")
# def register_user(user: User):
#     with Session(engine) as session:
#         # Vérifie si email existe déjà
#         existing = session.exec(select(User).where(User.email == user.email)).first()
#         if existing:
#             raise HTTPException(status_code=400, detail="Email déjà utilisé.")
        
#         user.password_hash = bcrypt.hash(user.password_hash)  # Hash le mot de passe
#         session.add(user)
#         session.commit()
#         session.refresh(user)
#         return {"message": "Utilisateur créé avec succès", "user_id": user.id}


# # POST - Connexion d'un utilisateur
# @app.post("/api/login")
# def login(email: str, password: str):
#     with Session(engine) as session:
#         user = session.exec(select(User).where(User.email == email)).first()
#         if not user or not bcrypt.verify(password, user.password_hash):
#             raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect.")
#         return {"message": "Connexion réussie", "user_id": user.id}




# # GET - Liste des profils
# @app.get("/api/profils")
# def get_profils():
#     with Session(engine) as session:
#         profils = session.exec(select(User)).all()
#         return profils

# # POST - Créer un utilisateur
# @app.post("/api/users")
# def create_user(user: User):
#     with Session(engine) as session:
#         session.add(user)
#         session.commit()
#         session.refresh(user)
#         return user

# # POST - Enregistrer une interaction (like/dislike/superlike)
# @app.post("/api/interact")
# def add_interaction(inter: Interaction):
#     with Session(engine) as session:
#         session.add(inter)
#         session.commit()
#         session.refresh(inter)
#         return inter

# # GET - Stats pour un utilisateur
# @app.get("/api/stats/{user_id}")
# def get_stats(user_id: int):
#     with Session(engine) as session:
#         interactions = session.exec(select(Interaction).where(Interaction.user_id == user_id)).all()

#         stats = {"likes": 0, "dislikes": 0, "superlikes": 0}
#         for inter in interactions:
#             if inter.action == "like":
#                 stats["likes"] += 1
#             elif inter.action == "dislike":
#                 stats["dislikes"] += 1
#             elif inter.action == "superlike":
#                 stats["superlikes"] += 1
#         return stats

# # POST - Reset des interactions
# @app.post("/api/reset")
# def reset_interactions():
#     with Session(engine) as session:
#         session.exec("DELETE FROM interaction")
#         session.commit()
#     return {"status": "Tous les compteurs ont été remis à zéro."}

# # POST - Authentification avec token
# @app.post("/api/token")
# def login_token(form_data: OAuth2PasswordRequestForm = Depends()):
#     with Session(engine) as session:
#         user = session.exec(select(User).where(User.email == form_data.username)).first()
#         if not user or not bcrypt.verify(form_data.password, user.password_hash):
#             raise HTTPException(status_code=401, detail="Identifiants invalides")

#         token = create_access_token(data={"sub": str(user.id)})
#         return {"access_token": token, "token_type": "bearer"}


# # GET - Obtenir les informations de l'utilisateur connecté
# @app.get("/api/me")
# def read_users_me(token: str = Depends(oauth2_scheme)):
#     user_id = verify_token(token)
#     if not user_id:
#         raise HTTPException(status_code=401, detail="Token invalide ou expiré")

#     with Session(engine) as session:
#         user = session.get(User, int(user_id))
#         if not user:
#             raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
#         return user

from fastapi import FastAPI, Depends, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import SQLModel, Session, create_engine, select
from passlib.hash import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta
import random
from .models import User, Interaction, Match, Message  # Ton fichier models.py
from pydantic import BaseModel


# import websocket pour messagerie instantanée
from fastapi import WebSocket, WebSocketDisconnect
from typing import List

# -----------------------
# Configurations JWT
# -----------------------
SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/token")

# -----------------------
# JWT Utils
# -----------------------
def create_access_token(data: dict, expires_delta: timedelta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None

def get_current_user(token: str = Depends(oauth2_scheme)):
    user_id = verify_token(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Token invalide ou expiré")
    with Session(engine) as session:
        user = session.get(User, int(user_id))
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        return user

# -----------------------
# Init FastAPI & DB
# -----------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

sqlite_file = "database.db"
engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

def init_db():
    SQLModel.metadata.create_all(engine)

init_db()

# -----------------------
# Endpoints
# -----------------------

# ✅ Enregistrement utilisateur
@app.post("/api/register")
def register_user(user: User):
    with Session(engine) as session:
        existing = session.exec(select(User).where(User.email == user.email)).first()
        if existing:
            raise HTTPException(status_code=400, detail="Email déjà utilisé.")
        user.password_hash = bcrypt.hash(user.password_hash)
        session.add(user)
        session.commit()
        session.refresh(user)
        return {"message": "Utilisateur créé avec succès", "user_id": user.id}

# ✅ Authentification : retourne un token JWT
@app.post("/api/token")
def login_token(form_data: OAuth2PasswordRequestForm = Depends()):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.email == form_data.username)).first()
        if not user or not bcrypt.verify(form_data.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Identifiants invalides")
        token = create_access_token(data={"sub": str(user.id)})
        return {"access_token": token, "token_type": "bearer"}

# ✅ Retourne l'utilisateur connecté
@app.get("/api/me")
def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

# ✅ Liste tous les profils (peut être publique ou protégée)
@app.get("/api/profils")
def get_profils():
    with Session(engine) as session:
        profils = session.exec(select(User)).all()
        random.shuffle(profils) # Mélange les profils pour la diversité
        return profils

# ✅ Enregistre une interaction (like/dislike/superlike)
# @app.post("/api/interact")
# def add_interaction(inter: Interaction, current_user: User = Depends(get_current_user)):
#     with Session(engine) as session:
#         inter.user_id = current_user.id
#         session.add(inter)
#         session.commit()
#         session.refresh(inter)
#         return inter
@app.post("/api/interact")
def add_interaction(inter: Interaction, current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        inter.user_id = current_user.id
        session.add(inter)
        session.commit()
        session.refresh(inter)

        # Vérifie si l'autre utilisateur a déjà liké l'utilisateur courant
        reciprocal = session.exec(
            select(Interaction).where(
                Interaction.user_id == inter.profil_id,
                Interaction.profil_id == current_user.id,
                Interaction.action == "like"
            )
        ).first()

        if inter.action == "like" and reciprocal:
            # Check si le match existe déjà
            existing_match = session.exec(
                select(Match).where(
                    ((Match.user1_id == current_user.id) & (Match.user2_id == inter.profil_id)) |
                    ((Match.user1_id == inter.profil_id) & (Match.user2_id == current_user.id))
                )
            ).first()

            if not existing_match:
                # Crée le match
                new_match = Match(user1_id=current_user.id, user2_id=inter.profil_id)
                session.add(new_match)
                session.commit()
                session.refresh(new_match)
                return {"interaction": inter, "match": True}

        return {"interaction": inter, "match": False}

# enpoint Matches 
@app.get("/api/matches")
def get_my_matches(current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        matches = session.exec(
            select(Match).where(
                (Match.user1_id == current_user.id) | (Match.user2_id == current_user.id)
            )
        ).all()

        matched_user_ids = [
            match.user2_id if match.user1_id == current_user.id else match.user1_id
            for match in matches
        ]

        users = session.exec(select(User).where(User.id.in_(matched_user_ids))).all()
        return users


# ✅ Stats de l’utilisateur connecté
@app.get("/api/stats/me")
def get_my_stats(current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        interactions = session.exec(
            select(Interaction).where(Interaction.user_id == current_user.id)
        ).all()

        stats = {"likes": 0, "dislikes": 0, "superlikes": 0}
        for inter in interactions:
            if inter.action in stats:
                stats[inter.action + "s"] += 1
        return stats

# ✅ Reset de toutes les interactions (admin uniquement ?)
@app.post("/api/resetALL")
def reset_interactions():
    with Session(engine) as session:
        # session.exec("DELETE FROM interaction")
        session.exec("DELETE FROM interaction") 
        session.commit()
    return {"status": "Tous les compteurs ont été remis à zéro."}



# Modèle pour le body de la requête
class ResetRequest(BaseModel):
    user_id: int

from sqlalchemy import text

@app.post("/api/reset")
def reset_user_interactions(request: ResetRequest):
    with Session(engine) as session:
        # Supprime uniquement les interactions de l'utilisateur spécifié
        session.exec(text("DELETE FROM interaction WHERE user_id = :user_id").bindparams(user_id=request.user_id))
        session.commit()
    return {"status": f"Les interactions de l'utilisateur {request.user_id} ont été supprimées."}
#------------------------CURL REQUEST-------------------
# curl -X POST "http://127.0.0.1:8000/api/reset" -H 
# "Content-Type: application/json" -d '{
#     "user_id": 1
# }'
#-------------------------------------------------------






@app.post("/api/registerLot")
def register_lot(users: list[User]):
    with Session(engine) as session:
        for user in users:
            # Vérifie si l'email existe déjà
            existing = session.exec(select(User).where(User.email == user.email)).first()
            if existing:
                raise HTTPException(status_code=400, detail=f"Email déjà utilisé : {user.email}")
            
            # Hash le mot de passe avant de l'enregistrer
            user.password_hash = bcrypt.hash(user.password_hash)
            session.add(user)
        session.commit()
    return {"message": "Utilisateurs créés avec succès"}

# GET - Stats pour un utilisateur
@app.get("/api/stats/{user_id}")
def get_stats(user_id: int):
    with Session(engine) as session:
        interactions = session.exec(select(Interaction).where(Interaction.user_id == user_id)).all()

        stats = {"likes": 0, "dislikes": 0, "superlikes": 0}
        for inter in interactions:
            if inter.action == "like":
                stats["likes"] += 1
            elif inter.action == "dislike":
                stats["dislikes"] += 1
            elif inter.action == "superlike":
                stats["superlikes"] += 1
        return stats


# Gestion des messages 

# Endpoint pour envoyer un message
# @app.post("/api/messages/send")
# def send_message(match_id: int, text: str, current_user: User = Depends(get_current_user)):
#     with Session(engine) as session:
#         match = session.get(Match, match_id)

#         if not match or (current_user.id not in [match.user1_id, match.user2_id]):
#             raise HTTPException(status_code=403, detail="Vous ne faites pas partie de ce match.")

#         msg = Message(
#             match_id=match_id,
#             sender_id=current_user.id,
#             text=text
#         )
#         session.add(msg)
#         session.commit()
#         session.refresh(msg)
#         return msg

class MessageRequest(BaseModel):
    match_id: int
    text: str

@app.post("/api/messages/send")
async def send_message(data: MessageRequest, current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        match = session.get(Match, data.match_id)

        if not match or (current_user.id not in [match.user1_id, match.user2_id]):
            raise HTTPException(status_code=403, detail="Vous ne faites pas partie de ce match.")

        msg = Message(
            match_id=data.match_id,
            sender_id=current_user.id,
            text=data.text
        )
        session.add(msg)
        session.commit()
        session.refresh(msg)
        
        # Envoi du message via WebSocket
        receiver_id = match.user2_id if match.user1_id == current_user.id else match.user1_id
        await manager.send_personal_message(
            {
                "match_id": msg.match_id,
                "sender_id": msg.sender_id,
                "text": msg.text,
                "timestamp": str(msg.timestamp),
            },
            receiver_id,
        )

        return msg

# Endpoint pour récupérer les messages d'un match
@app.get("/api/messages/{match_id}")
def get_messages(match_id: int, current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        match = session.get(Match, match_id)
        if not match or (current_user.id not in [match.user1_id, match.user2_id]):
            raise HTTPException(status_code=403, detail="Accès interdit à cette conversation.")

        messages = session.exec(
            select(Message)
            .where(Message.match_id == match_id)
            .order_by(Message.timestamp)
        ).all()

        return messages



# Gestion des connexions WebSocket par user_id
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}

    async def connect(self, user_id: int, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: int):
        self.active_connections.pop(user_id, None)

    async def send_personal_message(self, message: dict, user_id: int):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_json(message)

manager = ConnectionManager()

# @app.websocket("/ws/chat/{user_id}")
# async def websocket_endpoint(websocket: WebSocket, user_id: int):
#     await manager.connect(user_id, websocket)
#     try:
#         while True:
#             data = await websocket.receive_json()
#             receiver_id = data.get("receiver_id")
#             await manager.send_personal_message(data, receiver_id)
#     except WebSocketDisconnect:
#         manager.disconnect(user_id)

@app.websocket("/ws/chat/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()

            match_id = data.get("match_id")
            receiver_id = data.get("receiver_id")

            # Vérifie que le receiver_id est bien dans le match
            with Session(engine) as session:
                match = session.get(Match, match_id)

                if not match:
                    continue  # match non trouvé, on ignore

                if receiver_id not in [match.user1_id, match.user2_id]:
                    print(f"❌ User {receiver_id} n'est pas dans le match {match_id}")
                    continue

            await manager.send_personal_message(data, receiver_id)

    except WebSocketDisconnect:
        manager.disconnect(user_id)



# Endpoint pour voir tous les matchs avec dernier message
@app.get("/api/conversations")
def get_conversations(current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        matches = session.exec(
            select(Match).where(
                (Match.user1_id == current_user.id) | (Match.user2_id == current_user.id)
            )
        ).all()

        convs = []
        for match in matches:
            last_message = session.exec(
                select(Message)
                .where(Message.match_id == match.id)
                .order_by(Message.timestamp.desc())
            ).first()

            other_user_id = match.user2_id if match.user1_id == current_user.id else match.user1_id
            other_user = session.get(User, other_user_id)

            convs.append({
                "match_id": match.id,
                "user": {"id": other_user.id, "nom": other_user.nom, "image": other_user.image},
                "last_message": last_message.text if last_message else None,
                "last_timestamp": last_message.timestamp if last_message else None
            })

        return convs

# --- Nouveaux Endpoints pour le Profil ---
from .schemas import ProfileUpdate, ProfilePublic, Interest as InterestSchema
from .models import Lifestyle, Interest

# Endpoint pour pré-remplir les intérêts
@app.post("/api/seed-interests")
def seed_interests():
    # S'assurer que les tables sont créées dans la bdd en mémoire
    init_db()
    interests_data = [
        {"name": "Running", "category": "Sport & Fitness"},
        {"name": "Yoga", "category": "Sport & Fitness"},
        {"name": "Musculation", "category": "Sport & Fitness"},
        {"name": "Rock", "category": "Musique"},
        {"name": "Jazz", "category": "Musique"},
        {"name": "Action", "category": "Films & Séries"},
        {"name": "Comédie", "category": "Films & Séries"},
    ]
    with Session(engine) as session:
        existing_interests = session.exec(select(Interest)).all()
        if not existing_interests:
            for interest_data in interests_data:
                interest = Interest.model_validate(interest_data)
                session.add(interest)
            session.commit()
            return {"message": "Intérêts ajoutés avec succès."}
        return {"message": "Les intérêts existent déjà."}

# Endpoint pour lister tous les intérêts
@app.get("/api/interests", response_model=List[InterestSchema])
def get_interests():
    with Session(engine) as session:
        interests = session.exec(select(Interest)).all()
        return interests

# Endpoint pour voir un profil public
@app.get("/api/profile/{user_id}", response_model=ProfilePublic)
def get_user_profile(user_id: int):
    with Session(engine) as session:
        user = session.get(User, user_id, with_for_update=False)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

        # Ce mapping devra être amélioré si la structure de `ProfilePublic` devient plus complexe
        return user

# Endpoint pour mettre à jour son propre profil
@app.put("/api/profile/me", response_model=ProfilePublic)
def update_my_profile(profile_data: ProfileUpdate, current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        # 1. Mettre à jour les champs simples de l'utilisateur
        user_data = profile_data.model_dump(exclude_unset=True)
        for key, value in user_data.items():
            if key not in ["lifestyle", "interest_ids"]:
                setattr(current_user, key, value)

        # 2. Mettre à jour le style de vie
        if profile_data.lifestyle:
            if current_user.lifestyle:
                lifestyle_data = profile_data.lifestyle.model_dump(exclude_unset=True)
                for key, value in lifestyle_data.items():
                    setattr(current_user.lifestyle, key, value)
            else:
                lifestyle = Lifestyle.model_validate(profile_data.lifestyle, update={"user_id": current_user.id})
                current_user.lifestyle = lifestyle

        # 3. Mettre à jour les intérêts
        if profile_data.interest_ids is not None:
            # Récupère les objets Interest correspondants aux IDs
            interests = session.exec(select(Interest).where(Interest.id.in_(profile_data.interest_ids))).all()
            current_user.interests = interests

        session.add(current_user)
        session.commit()
        session.refresh(current_user)
        return current_user

# --- Endpoints pour la gestion des photos ---

@app.post("/api/profile/me/photos")
async def upload_photos(files: List[UploadFile] = File(...), current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        if len(current_user.photos) + len(files) > 9:
            raise HTTPException(status_code=400, detail="Vous ne pouvez pas avoir plus de 9 photos.")

        for file in files:
            # Simulation du stockage: on utilise une URL fictive.
            # Dans une vraie application, on uploaderait sur S3, Cloudinary, etc.
            # et on enregistrerait l'URL retournée.
            photo_url = f"https://picsum.photos/seed/{current_user.id}_{file.filename}/400/600"

            # Détermine la position de la nouvelle photo
            new_position = len(current_user.photos) + 1

            photo = Photo(url=photo_url, user_id=current_user.id, position=new_position)
            session.add(photo)

        session.commit()
        session.refresh(current_user)
        return current_user.photos

class PhotoOrder(BaseModel):
    photo_ids: List[int]

@app.put("/api/profile/me/photos/order")
def reorder_photos(order: PhotoOrder, current_user: User = Depends(get_current_user)):
    with Session(engine) as session:
        if len(order.photo_ids) != len(current_user.photos):
            raise HTTPException(status_code=400, detail="La liste des IDs de photos ne correspond pas au nombre de photos de l'utilisateur.")

        for i, photo_id in enumerate(order.photo_ids):
            photo = session.get(Photo, photo_id)
            if photo and photo.user_id == current_user.id:
                photo.position = i + 1
                session.add(photo)

        session.commit()
        return {"message": "L'ordre des photos a été mis à jour."}

# --- Endpoint pour la Vérification de Profil ---

@app.post("/api/users/verify")
async def verify_profile(selfie: UploadFile = File(...), current_user: User = Depends(get_current_user)):
    # --- Simulation de la vérification par ML ---
    # Dans une application réelle, vous appelleriez ici un service de reconnaissance faciale.
    # Pour cette démo, nous allons simuler un succès aléatoire.
    import random

    # 1. On vérifie que l'utilisateur a au moins une photo de profil
    if not current_user.photos:
        raise HTTPException(status_code=400, detail="Veuillez ajouter au moins une photo à votre profil avant de demander la vérification.")

    # 2. Simulation de la comparaison
    similarity_score = random.uniform(0.7, 0.99) # Score aléatoire

    with Session(engine) as session:
        if similarity_score > 0.85:
            current_user.is_verified = True
            current_user.verified_at = datetime.utcnow()
            session.add(current_user)
            session.commit()
            return {"verified": True, "score": similarity_score}
        else:
            return {"verified": False, "reason": "Les visages ne correspondent pas.", "score": similarity_score}
