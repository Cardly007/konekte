from sqlalchemy import (
    Column, String, Text, Boolean, DateTime, ForeignKey
)
from .base import DeclarativeBase

class Message(DeclarativeBase):
    __tablename__ = 'messages'

    match_id = Column(ForeignKey('matches.id', ondelete='CASCADE'), nullable=False, index=True)
    sender_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)

    content_type = Column(String(20), default='text')
    text_content = Column(Text)
    media_url = Column(Text)

    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime)

    is_flagged = Column(Boolean, default=False)
    flag_reason = Column(Text)
