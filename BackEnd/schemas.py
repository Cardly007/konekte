from pydantic import BaseModel
from typing import Optional, List

# Schéma pour un intérêt
class InterestBase(BaseModel):
    name: str
    category: str

class InterestCreate(InterestBase):
    pass

class Interest(InterestBase):
    id: int

    class Config:
        orm_mode = True

# Schéma pour le style de vie
class LifestyleBase(BaseModel):
    drinking: Optional[str] = None
    smoking: Optional[str] = None
    workout: Optional[str] = None
    diet_preference: Optional[str] = None
    pets: Optional[str] = None
    political_views: Optional[str] = None
    religion: Optional[str] = None
    relationship_goal: Optional[str] = None

class LifestyleCreate(LifestyleBase):
    pass

class Lifestyle(LifestyleBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True

# Schéma pour la mise à jour du profil utilisateur
class ProfileUpdate(BaseModel):
    nom: Optional[str] = None
    age: Optional[int] = None
    description: Optional[str] = None
    job: Optional[str] = None
    company: Optional[str] = None
    school: Optional[str] = None
    height: Optional[int] = None
    living_in: Optional[str] = None
    hometown: Optional[str] = None
    gender: Optional[str] = None
    pronouns: Optional[str] = None
    lifestyle: Optional[LifestyleBase] = None
    interest_ids: Optional[List[int]] = None

# Schéma pour l'affichage public du profil
class ProfilePublic(BaseModel):
    id: int
    nom: str
    age: Optional[int] = None
    description: Optional[str] = None
    job: Optional[str] = None
    company: Optional[str] = None
    school: Optional[str] = None
    height: Optional[int] = None
    living_in: Optional[str] = None
    is_verified: bool

    photos: List = [] # Sera une liste de schémas Photo
    lifestyle: Optional[LifestyleBase] = None
    interests: List[Interest] = []

    class Config:
        orm_mode = True
