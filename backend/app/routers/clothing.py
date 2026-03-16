from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.clothing import ClothingItem, ClothingItemCreate, ClothingItemUpdate
from app.schemas.user import User
from app.services import clothing_service
from app.utils.deps import get_current_user

router = APIRouter()

@router.get("/", response_model=List[ClothingItem])
async def read_clothing_items(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Retrieve all clothing items for current user."""
    items = await clothing_service.get_clothing_items(db, user_id=current_user.id)
    return items

@router.post("/", response_model=ClothingItem)
async def create_clothing_item(
    item_in: ClothingItemCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Create new clothing item."""
    # Optional: Check if item config already exists
    existing_item = await clothing_service.get_clothing_item(db, item_id=item_in.id, user_id=current_user.id)
    if existing_item:
        raise HTTPException(status_code=400, detail="Item with this ID already exists")

    return await clothing_service.create_clothing_item(db, item_in=item_in, user_id=current_user.id)

@router.get("/{item_id}", response_model=ClothingItem)
async def read_clothing_item(
    item_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Get single clothing item."""
    item = await clothing_service.get_clothing_item(db, item_id=item_id, user_id=current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Clothing item not found")
    return item

@router.put("/{item_id}", response_model=ClothingItem)
async def update_clothing_item(
    item_id: str,
    item_update: ClothingItemUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Update a clothing item."""
    item = await clothing_service.get_clothing_item(db, item_id=item_id, user_id=current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Clothing item not found")
    return await clothing_service.update_clothing_item(db, db_item=item, item_update=item_update)

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_clothing_item(
    item_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Delete a clothing item."""
    item = await clothing_service.get_clothing_item(db, item_id=item_id, user_id=current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Clothing item not found")
    await clothing_service.delete_clothing_item(db, item_id=item_id, user_id=current_user.id)
    return None
