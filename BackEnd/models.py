from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime

# Table de liaison pour la relation plusieurs-à-plusieurs entre User et Interest
class UserInterestLink(SQLModel, table=True):
    user_id: Optional[int] = Field(
        default=None, foreign_key="user.id", primary_key=True
    )
    interest_id: Optional[int] = Field(
        default=None, foreign_key="interest.id", primary_key=True
    )

class Interest(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    category: str

    users: List["User"] = Relationship(back_populates="interests", link_model=UserInterestLink)

class Photo(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    url: str
    position: int  # Pour gérer l'ordre
    user_id: Optional[int] = Field(default=None, foreign_key="user.id")

    user: "User" = Relationship(back_populates="photos")

class Lifestyle(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    drinking: Optional[str] = None
    smoking: Optional[str] = None
    workout: Optional[str] = None
    diet_preference: Optional[str] = None
    pets: Optional[str] = None
    political_views: Optional[str] = None
    religion: Optional[str] = None
    relationship_goal: Optional[str] = None

    user_id: Optional[int] = Field(default=None, foreign_key="user.id")
    user: "User" = Relationship(back_populates="lifestyle")

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)

    # Informations de base
    nom: str
    age: Optional[int] = None
    email: str = Field(unique=True, index=True)
    password_hash: str
    description: Optional[str] = None  # Bio principale (500 caractères)

    # Informations de profil ajoutées
    job: Optional[str] = None
    company: Optional[str] = None
    school: Optional[str] = None
    height: Optional[int] = None  # En cm
    living_in: Optional[str] = None
    hometown: Optional[str] = None
    gender: Optional[str] = None
    pronouns: Optional[str] = None

    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Vérification
    is_verified: bool = Field(default=False)
    verified_at: Optional[datetime] = None

    # Relations
    photos: List[Photo] = Relationship(back_populates="user")
    lifestyle: Optional[Lifestyle] = Relationship(back_populates="user", sa_relationship_kwargs={'uselist': False})
    interests: List[Interest] = Relationship(back_populates="users", link_model=UserInterestLink)

class Interaction(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int
    profil_id: int
    action: str  # like, dislike, superlike
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class Match(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user1_id: int
    user2_id: int
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    match_id: int
    sender_id: int
    text: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
