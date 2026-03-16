from sqlalchemy import String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base

class CalendarEvent(Base):
    __tablename__ = "calendar_events"

    id: Mapped[str] = mapped_column(String, primary_key=True, index=True) # UUID
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    date: Mapped[DateTime] = mapped_column(DateTime(timezone=True), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    
    # Optional outfit linked to this event
    outfit_id: Mapped[str] = mapped_column(ForeignKey("outfits.id", ondelete="SET NULL"), nullable=True)

    user = relationship("User", back_populates="calendar_events")
    outfit = relationship("Outfit", back_populates="calendar_events")
