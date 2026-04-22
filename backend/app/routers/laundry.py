from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.laundry import LaundryItem, LaundryItemCreate, LaundryItemUpdate
from app.schemas.user import User
from app.services import laundry_service
from app.utils.deps import get_current_user

router = APIRouter()

@router.get("/")
async def read_laundry_items(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Retrieve all laundry items for current user. Auto-creates records for new clothing items."""
    # Ensure all clothing items have a laundry record
    await laundry_service.ensure_laundry_for_user(db, user_id=current_user.id)
    
    items = await laundry_service.get_laundry_items(db, user_id=current_user.id)
    
    # Build response with clothing_item info included
    result = []
    for item in items:
        item_dict = {
            "id": item.id,
            "user_id": item.user_id,
            "clothing_item_id": item.clothing_item_id,
            "name": item.name,
            "category": item.category,
            "wear_count": item.wear_count,
            "max_wear": item.max_wear,
            "icon_name": item.icon_name,
            "status": item.status.value if item.status else "clean",
            "updated_at": item.updated_at.isoformat() if item.updated_at else None,
            "clothing_item": {
                "id": item.clothing_item.id,
                "name": item.clothing_item.name,
                "category": item.clothing_item.category,
                "color": item.clothing_item.color,
                "image_url": item.clothing_item.image_url,
            } if item.clothing_item else None,
        }
        result.append(item_dict)
    
    return result

@router.post("/", response_model=LaundryItem)
async def create_laundry_item(
    item_in: LaundryItemCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Create new laundry link for a clothing item."""
    existing_item = await laundry_service.get_laundry_item_by_clothing(db, clothing_item_id=item_in.clothing_item_id, user_id=current_user.id)
    if existing_item:
        raise HTTPException(status_code=400, detail="Laundry record for this clothing item already exists")

    return await laundry_service.create_laundry_item(db, item_in=item_in, user_id=current_user.id)

@router.patch("/{item_id}/status", response_model=LaundryItem)
async def update_laundry_status(
    item_id: str,
    status: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Update laundry status (needsWash, washing, clean)"""
    item = await laundry_service.get_laundry_item(db, item_id=item_id, user_id=current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Laundry item not found")
        
    update_data = LaundryItemUpdate(status=status)
    if status == "clean":
        update_data.wear_count = 0
    elif status == "needsWash":
        update_data.wear_count = item.max_wear
        
    return await laundry_service.update_laundry_item(db, db_item=item, item_update=update_data)

@router.patch("/{item_id}/wear", response_model=LaundryItem)
async def increment_wear(
    item_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Increment wear count by 1. Auto-sets to 'needsWash' if max_wear is reached."""
    item = await laundry_service.get_laundry_item(db, item_id=item_id, user_id=current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Laundry item not found")
        
    new_wear = item.wear_count + 1
    update_data = LaundryItemUpdate(wear_count=new_wear)
    
    if new_wear >= item.max_wear:
        update_data.status = "needsWash"
        update_data.wear_count = item.max_wear
        
    return await laundry_service.update_laundry_item(db, db_item=item, item_update=update_data)
