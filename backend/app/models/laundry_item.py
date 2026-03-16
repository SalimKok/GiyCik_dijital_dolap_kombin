import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
import enum
from app.database import Base

class LaundryStatusEnum(str, enum.Enum):
    needsWash = "needsWash"
    washing = "washing"
    clean = "clean"

class LaundryItem(Base):
    __tablename__ = "laundry_items"

    id: Mapped[str] = mapped_column(String, primary_key=True, index=True) # UUID
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    clothing_item_id: Mapped[str] = mapped_column(ForeignKey("clothing_items.id", ondelete="CASCADE"), unique=True)
    
    # Store redundant data for easy query matching flutter model if needed, or rely on clothing_item relation
    name: Mapped[str] = mapped_column(String(100))
    category: Mapped[str] = mapped_column(String(50))
    wear_count: Mapped[int] = mapped_column(Integer, default=0)
    max_wear: Mapped[int] = mapped_column(Integer, default=3)
    icon_name: Mapped[str] = mapped_column(String(50), nullable=True)
    
    status: Mapped[LaundryStatusEnum] = mapped_column(Enum(LaundryStatusEnum), default=LaundryStatusEnum.clean)
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

    user = relationship("User", back_populates="laundry_items")
    clothing_item = relationship("ClothingItem", back_populates="laundry_record")
