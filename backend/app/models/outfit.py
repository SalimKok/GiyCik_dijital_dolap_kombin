import datetime
from sqlalchemy import String, Boolean, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from app.database import Base

class Outfit(Base):
    __tablename__ = "outfits"

    id: Mapped[str] = mapped_column(String, primary_key=True, index=True) # UUID
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    style: Mapped[str] = mapped_column(String(50), nullable=False)
    season: Mapped[str] = mapped_column(String(50), nullable=False)
    is_favorite: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="outfits")
    items = relationship("OutfitItemLink", back_populates="outfit", cascade="all, delete-orphan")
    calendar_events = relationship("CalendarEvent", back_populates="outfit")

class OutfitItemLink(Base):
    __tablename__ = "outfit_items"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    outfit_id: Mapped[str] = mapped_column(ForeignKey("outfits.id", ondelete="CASCADE"), index=True)
    clothing_item_id: Mapped[str] = mapped_column(ForeignKey("clothing_items.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(100)) # e.g. "Beyaz Gömlek" (snapshot or override)
    icon_name: Mapped[str] = mapped_column(String(50), nullable=True) # e.g. "dry_cleaning_rounded"
    display_order: Mapped[int] = mapped_column(Integer, default=0)

    outfit = relationship("Outfit", back_populates="items")
    clothing_item = relationship("ClothingItem", back_populates="outfit_links")
