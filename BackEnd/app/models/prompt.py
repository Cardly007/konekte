from sqlalchemy import (
    Column, String, Text, Boolean, Integer, ForeignKey
)
from sqlalchemy.orm import relationship
from .base import DeclarativeBase

class Prompt(DeclarativeBase):
    __tablename__ = 'prompts'

    category = Column(String(50), nullable=False)
    question = Column(Text, nullable=False)
    locale = Column(String(10), default='fr-FR')
    is_active = Column(Boolean, default=True)

class UserPrompt(DeclarativeBase):
    __tablename__ = 'user_prompts'

    user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    prompt_id = Column(ForeignKey('prompts.id'), nullable=False)
    answer = Column(Text, nullable=False)
    display_order = Column(Integer)
