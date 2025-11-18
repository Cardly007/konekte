from sqlalchemy import (
    Column, String, ForeignKey, DECIMAL
)
from .base import DeclarativeBase

class Interaction(DeclarativeBase):
    __tablename__ = 'interactions'

    user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    target_user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    action = Column(String(20), nullable=False) # 'like', 'dislike', 'superlike'
    distance_km = Column(DECIMAL(10, 2))
