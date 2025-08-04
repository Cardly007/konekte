from sqlmodel import SQLModel, Field
from typing import Optional
from datetime import datetime

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    nom: str
    age: Optional[int] = None
    email: str
    password_hash: str
    description: Optional[str] = None
    image: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Interaction(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int
    profil_id: int
    action: str  # like, dislike, superlike
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# Gestion des matches
class Match(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user1_id: int
    user2_id: int
    created_at: datetime = Field(default_factory=datetime.utcnow)

# Gestion des conversations 
class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    match_id: int
    sender_id: int
    text: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
