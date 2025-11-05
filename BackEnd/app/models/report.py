from sqlalchemy import (
    Column, String, Text, DateTime, ForeignKey
)
from .base import DeclarativeBase

class Report(DeclarativeBase):
    __tablename__ = 'reports'

    reporter_id = Column(ForeignKey('users.id', ondelete='SET NULL'), index=True)
    reported_user_id = Column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)

    report_type = Column(String(50), nullable=False)
    reason = Column(Text)

    # Context (optional)
    reported_message_id = Column(ForeignKey('messages.id'))
    reported_photo_id = Column(ForeignKey('photos.id'))

    # Moderation status
    status = Column(String(20), default='pending', index=True)
    action_taken = Column(String(50))
    reviewed_at = Column(DateTime)
