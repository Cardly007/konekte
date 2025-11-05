from sqlalchemy import (
    Column, String, Boolean, ForeignKey
)
from sqlalchemy.orm import relationship
from .base import DeclarativeBase

class Interest(DeclarativeBase):
    __tablename__ = 'interests'

    category = Column(String(50), nullable=False)
    name = Column(String(100), nullable=False)
    emoji = Column(String(10))
    locale = Column(String(10), default='fr-FR')
    is_active = Column(Boolean, default=True)

class UserInterest(DeclarativeBase):
    __tablename__ = 'user_interests'

    user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    interest_id = Column(ForeignKey('interests.id'), primary_key=True)
