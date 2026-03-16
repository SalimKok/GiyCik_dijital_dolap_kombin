from typing import Optional
from pydantic import BaseModel
from datetime import datetime

# Shared properties
class CalendarEventBase(BaseModel):
    date: datetime
    title: str

# Properties to receive on item creation
class CalendarEventCreate(CalendarEventBase):
    id: str # UUID from frontend
    outfit_id: Optional[str] = None

# Properties to receive on item update
class CalendarEventUpdate(BaseModel):
    title: Optional[str] = None
    date: Optional[datetime] = None
    outfit_id: Optional[str] = None

# Properties shared by models stored in DB
class CalendarEventInDBBase(CalendarEventBase):
    id: str
    user_id: int
    outfit_id: Optional[str] = None

    class Config:
        from_attributes = True

# Properties to return to client
class CalendarEvent(CalendarEventInDBBase):
    pass
