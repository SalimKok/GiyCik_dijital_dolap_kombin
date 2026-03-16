import datetime
from sqlalchemy import Integer, DateTime, ForeignKey, Enum, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
import enum
from app.database import Base

class SubscriptionPlanEnum(str, enum.Enum):
    free = "free"
    monthly = "monthly"
    yearly = "yearly"

class Subscription(Base):
    __tablename__ = "subscriptions"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    plan: Mapped[SubscriptionPlanEnum] = mapped_column(Enum(SubscriptionPlanEnum), default=SubscriptionPlanEnum.free)
    
    # Usage tracking counters
    clothing_item_count: Mapped[int] = mapped_column(Integer, default=0)
    outfit_count: Mapped[int] = mapped_column(Integer, default=0)
    ai_usages_today: Mapped[int] = mapped_column(Integer, default=0)
    calendar_event_count: Mapped[int] = mapped_column(Integer, default=0)
    
    last_ai_usage_date: Mapped[datetime.date] = mapped_column(nullable=True)
    
    started_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    expires_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="subscription")
