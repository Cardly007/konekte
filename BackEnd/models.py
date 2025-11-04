from sqlmodel import Relationship, SQLModel, Field
from typing import Optional, List
from datetime import datetime, date
import json # Import nécessaire pour le champ JSON futur si l'on ne crée pas de modèle séparé
from sqlalchemy import JSON, Boolean, Column, func # Import pour le type JSON et les fonctions SQL


# --- MODÈLES DE LIAISON ---
class UserInterestLink(SQLModel, table=True):
    user_id: Optional[int] = Field(default=None, foreign_key="user.id", primary_key=True)
    interest_id: Optional[int] = Field(default=None, foreign_key="interest.id", primary_key=True)

# --- MODÈLES DE BASE ---
class Interest(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    category: str
    users: List["User"] = Relationship(back_populates="interests", link_model=UserInterestLink)

# --- NOUVEAU MODÈLE POUR LES PHOTOS (support des photos multiples) ---
class PhotoBase(SQLModel):
    url: str = Field(index=True)
    order: int = Field(default=0) # Ordre d'affichage

class Photo(PhotoBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(index=True, foreign_key="user.id")

    user: "User" = Relationship(back_populates="photos")

# Modèle pour la lecture/réponse API des photos
class PhotoRead(PhotoBase):
    id: int
# ----------------------------------------------------------------------


# --- MODÈLE DE PRÉFÉRENCE (support des filtres de recherche) ---
class PreferenceBase(SQLModel):
    min_age: int = Field(default=18)
    max_age: int = Field(default=55)
    max_distance_km: int = Field(default=50)
    target_gender: str = Field(default="everyone") # 'male', 'female', 'everyone'

class Preference(PreferenceBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(index=True, foreign_key="user.id", unique=True)

    user: "User" = Relationship(back_populates="preference")
# ----------------------------------------------------------------------


# --- NOUVEAUX MODÈLES DE LECTURE ---
class LifestyleRead(SQLModel):
    drinking: Optional[str] = None
    smoking: Optional[str] = None
    workout: Optional[str] = None
    diet_preference: Optional[str] = None
    pets: Optional[str] = None

class InterestRead(SQLModel):
    id: int
    name: str
    category: str

# --- MODÈLE UTILISATEUR CONSOLIDÉ ---
class UserBase(SQLModel):
    # Champs du modèle original
    nom: str # Nous utiliserons ceci comme full_name/display_name
    email: str = Field(index=True, unique=True)
    description: Optional[str] = None # L'ancienne description

    # Nouveaux champs pour un profil riche
    username: Optional[str] = Field(index=True, unique=True, default=None) # Ajouté pour un nom d'utilisateur unique
    birthdate: Optional[date] = Field(default=None)
    job: Optional[str] = None
    company: Optional[str] = None
    school: Optional[str] = None
    latitude: Optional[float] = Field(default=None, index=True)
    longitude: Optional[float] = Field(default=None, index=True)
    last_seen: Optional[datetime] = Field(default_factory=datetime.utcnow)
    gender: Optional[str] = Field(default=None)
    orientation: Optional[str] = Field(default=None)
    fcm_token: Optional[str] = Field(default=None, index=False) # Pour les notifications push

# Le modèle de table User
class User(UserBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    # Remplaçons l'ancien 'password_hash' par 'hashed_password' pour la clarté
    hashed_password: str

    # Relations
    photos: List[Photo] = Relationship(back_populates="user")
    preference: Optional[Preference] = Relationship(back_populates="user")
    lifestyle: Optional["Lifestyle"] = Relationship(back_populates="user", sa_relationship_kwargs={'uselist': False})
    interests: List[Interest] = Relationship(back_populates="users", link_model=UserInterestLink)


    # Interactions (like/dislike)
    interactions_as_user: List["Interaction"] = Relationship(back_populates="user", sa_relationship_kwargs={"foreign_keys": "Interaction.user_id"})
    interactions_as_profil: List["Interaction"] = Relationship(back_populates="profil", sa_relationship_kwargs={"foreign_keys": "Interaction.profil_id"})

    # Matches
    matches_as_user1: List["Match"] = Relationship(back_populates="user1", sa_relationship_kwargs={"foreign_keys": "Match.user1_id"})
    matches_as_user2: List["Match"] = Relationship(back_populates="user2", sa_relationship_kwargs={"foreign_keys": "Match.user2_id"})

    # Messages
    messages_sent: List["Message"] = Relationship(back_populates="sender", sa_relationship_kwargs={"foreign_keys": "Message.sender_id"})

# Modèle pour la création
class UserCreate(UserBase):
    password: str
    birthdate: date

# Modèle pour la lecture (le résultat exposé par l'API)
class UserRead(UserBase):
    id: int
    photos: List[PhotoRead] = []
    lifestyle: Optional[LifestyleRead] = None
    interests: List[InterestRead] = []


# --- MODÈLES D'INTERACTION ET DE CHAT ---
class Interaction(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    profil_id: int = Field(foreign_key="user.id", index=True)
    action: str  # like, dislike, superlike
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    user: User = Relationship(back_populates="interactions_as_user", sa_relationship_kwargs={"foreign_keys": "Interaction.user_id"})
    profil: User = Relationship(back_populates="interactions_as_profil", sa_relationship_kwargs={"foreign_keys": "Interaction.profil_id"})

# Gestion des matches
class Match(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user1_id: int = Field(foreign_key="user.id", index=True)
    user2_id: int = Field(foreign_key="user.id", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    messages: List["Message"] = Relationship(back_populates="match")
    user1: User = Relationship(back_populates="matches_as_user1", sa_relationship_kwargs={"foreign_keys": "Match.user1_id"})
    user2: User = Relationship(back_populates="matches_as_user2", sa_relationship_kwargs={"foreign_keys": "Match.user2_id"})

# Mise à jour du Message (pour inclure le statut de lecture)
class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    match_id: int = Field(foreign_key="match.id")
    sender_id: int = Field(foreign_key="user.id")
    text: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    is_read: bool = Field(default=False, sa_column=Column(Boolean(), default=False))

    match: Match = Relationship(back_populates="messages")
    sender: User = Relationship(back_populates="messages_sent", sa_relationship_kwargs={"foreign_keys": "Message.sender_id"})

class LocationUpdate(SQLModel):
    latitude: float
    longitude: float

class Lifestyle(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    drinking: Optional[str] = None
    smoking: Optional[str] = None
    workout: Optional[str] = None
    diet_preference: Optional[str] = None
    pets: Optional[str] = None

    user_id: int = Field(foreign_key="user.id")
    user: User = Relationship(back_populates="lifestyle")
