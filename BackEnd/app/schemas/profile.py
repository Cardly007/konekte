from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class Photo(BaseModel):
    id: str
    cloudinary_url: str
    display_order: int

    class Config:
        orm_mode = True

class ProfileBase(BaseModel):
    first_name: str
    date_of_birth: date
    gender: str
    bio: Optional[str] = None
    height: Optional[int] = None
    occupation: Optional[str] = None
    education: Optional[str] = None

class ProfileUpdate(ProfileBase):
    pass

class ProfileRead(ProfileBase):
    id: str
    user_id: str
    photos: List[Photo] = []

    class Config:
        orm_mode = True
