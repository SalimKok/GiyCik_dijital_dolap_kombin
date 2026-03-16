from typing import Optional
from pydantic import BaseModel
from datetime import datetime
from app.models.subscription import SubscriptionPlanEnum

# Shared properties
class SubscriptionBase(BaseModel):
    plan: SubscriptionPlanEnum

# Properties to receive on item creation
class SubscriptionCreate(SubscriptionBase):
    pass

# Properties to receive on item update
class SubscriptionUpdate(BaseModel):
    plan: Optional[SubscriptionPlanEnum] = None
    clothing_item_count: Optional[int] = None
    outfit_count: Optional[int] = None
    ai_usages_today: Optional[int] = None
    calendar_event_count: Optional[int] = None

# Properties shared by models stored in DB
class SubscriptionInDBBase(SubscriptionBase):
    id: int
    user_id: int
    clothing_item_count: int
    outfit_count: int
    ai_usages_today: int
    calendar_event_count: int
    started_at: datetime
    expires_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# Properties to return to client
class Subscription(SubscriptionInDBBase):
    pass
