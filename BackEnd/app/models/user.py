from sqlalchemy import (
    Column, String, Boolean, DateTime, Text
)
from sqlalchemy.orm import relationship
from .base import DeclarativeBase

class User(DeclarativeBase):
    __tablename__ = 'users'

    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True)
    phone_verified = Column(Boolean, default=False)

    # Auth details
    auth_provider = Column(String(50), nullable=False)
    auth_provider_id = Column(String(255))
    password_hash = Column(String(255))

    # User status
    status = Column(String(20), default='active', index=True)
    ban_reason = Column(Text)
    ban_until = Column(DateTime)

    # Premium subscription details
    subscription_tier = Column(String(20), default='free')
    subscription_status = Column(String(20))
    subscription_expires_at = Column(DateTime)
    stripe_customer_id = Column(String(255))

    # Metadata
    last_active_at = Column(DateTime, index=True)
    device_token = Column(String(255))
    locale = Column(String(10), default='fr-FR')
    timezone = Column(String(50), default='Europe/Paris')
    deleted_at = Column(DateTime)

    # Relationships
    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    photos = relationship("Photo", back_populates="user", cascade="all, delete-orphan")
    # Add other relationships as models are created...
