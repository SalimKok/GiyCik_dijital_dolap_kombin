import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, LargeBinary
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from app.database import Base

class ClothingItem(Base):
    __tablename__ = "clothing_items"

    id: Mapped[str] = mapped_column(String, primary_key=True, index=True) # UUID defined in frontend
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)
    color: Mapped[str] = mapped_column(String(50), nullable=False)
    image_url: Mapped[str] = mapped_column(String(255), nullable=True)
    usage_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="clothing_items")
    outfit_links = relationship("OutfitItemLink", back_populates="clothing_item", cascade="all, delete-orphan")
    laundry_record = relationship("LaundryItem", back_populates="clothing_item", uselist=False, cascade="all, delete-orphan")

class ClothingImage(Base):
    __tablename__ = "clothing_images"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    data: Mapped[bytes] = mapped_column(LargeBinary, nullable=False)
    mime_type: Mapped[str] = mapped_column(String(50), nullable=False)
