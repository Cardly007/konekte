from sqlalchemy import (
    Column, String, ForeignKey, DateTime, Integer
)
from .base import DeclarativeBase

class Match(DeclarativeBase):
    __tablename__ = 'matches'

    user1_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    user2_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)

    status = Column(String(20), default='active') # 'active', 'unmatched_by_user1', etc.
    unmatched_at = Column(DateTime)

    # Stats for chat
    messages_count = Column(Integer, default=0)
    last_message_at = Column(DateTime)
