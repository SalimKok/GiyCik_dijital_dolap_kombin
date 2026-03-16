from typing import Optional
from pydantic import BaseModel
from datetime import datetime

# Shared properties
class LaundryItemBase(BaseModel):
    name: str
    category: str
    wear_count: int = 0
    max_wear: int = 3
    icon_name: Optional[str] = None
    status: str = "clean" # needsWash, washing, clean

# Properties to receive on item creation
class LaundryItemCreate(LaundryItemBase):
    id: str # UUID from frontend
    clothing_item_id: str

# Properties to receive on item update
class LaundryItemUpdate(BaseModel):
    wear_count: Optional[int] = None
    max_wear: Optional[int] = None
    status: Optional[str] = None

# Properties shared by models stored in DB
class LaundryItemInDBBase(LaundryItemBase):
    id: str
    user_id: int
    clothing_item_id: str
    updated_at: datetime

    class Config:
        from_attributes = True

# Properties to return to client
class LaundryItem(LaundryItemInDBBase):
    pass
