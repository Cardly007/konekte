from sqlalchemy import (
    Column, String, Date, Integer, Text, Boolean, DateTime, ForeignKey, DECIMAL
)
from sqlalchemy.orm import relationship
from .base import DeclarativeBase

class Profile(DeclarativeBase):
    __tablename__ = 'profiles'

    user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False, index=True)

    # Basic Info
    first_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    gender = Column(String(20), nullable=False)

    # Location
    location_lat = Column(DECIMAL(10, 8))
    location_lng = Column(DECIMAL(11, 8))
    location_city = Column(String(100))
    location_country = Column(String(100), default='France')

    # Bio & Prompts
    bio = Column(Text)

    # Lifestyle
    height = Column(Integer)
    education = Column(String(50))
    occupation = Column(String(100))
    company = Column(String(100))
    relationship_goal = Column(String(50))
    has_children = Column(String(20))
    wants_children = Column(String(20))
    smoking = Column(String(20))
    drinking = Column(String(20))
    exercise = Column(String(20))

    # Socials
    instagram_handle = Column(String(100))
    spotify_id = Column(String(100))

    # Verification
    is_verified = Column(Boolean, default=False)
    verified_at = Column(DateTime)

    # Discovery Preferences
    show_gender = Column(String(20))
    age_min = Column(Integer, default=18)
    age_max = Column(Integer, default=80)
    distance_max = Column(Integer, default=50)

    # Stats
    profile_views = Column(Integer, default=0)
    profile_completeness = Column(Integer, default=0)

    # Relationships
    user = relationship("User", back_populates="profile")
