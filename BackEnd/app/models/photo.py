from sqlalchemy import (
    Column, String, Integer, Text, Boolean, DateTime, ForeignKey
)
from sqlalchemy.orm import relationship
from .base import DeclarativeBase

class Photo(DeclarativeBase):
    __tablename__ = 'photos'

    user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)

    cloudinary_public_id = Column(String(255), nullable=False)
    cloudinary_url = Column(Text, nullable=False)
    cloudinary_secure_url = Column(Text, nullable=False)
    display_order = Column(Integer, nullable=False)

    # Moderation
    moderation_status = Column(String(20), default='pending', index=True)
    moderation_reason = Column(Text)
    moderated_at = Column(DateTime)

    # AI Analysis from Cloudinary
    has_face = Column(Boolean)
    is_inappropriate = Column(Boolean, default=False)

    # Relationships
    user = relationship("User", back_populates="photos")
