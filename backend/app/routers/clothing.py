from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Response
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from sqlalchemy import select

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

@router.post("/upload", response_model=dict)
async def upload_clothing_image(
    file: UploadFile = File(...),
    current_user: Annotated[User, Depends(get_current_user)] = None,
    db: AsyncSession = Depends(get_db)
):
    """Upload an image for a clothing item to Database and return its URL."""
    image_id = uuid.uuid4().hex
    data = await file.read()
    mime_type = file.content_type or "image/jpeg"
    
    from app.models.clothing_item import ClothingImage
    db_image = ClothingImage(id=image_id, data=data, mime_type=mime_type)
    db.add(db_image)
    await db.commit()
    
    return {"url": f"/api/clothing/image/{image_id}"}
    
@router.get("/image/{image_id}")
async def get_clothing_image(image_id: str, db: AsyncSession = Depends(get_db)):
    """Retrieve an image from Database directly."""
    from app.models.clothing_item import ClothingImage
    
    result = await db.execute(select(ClothingImage).where(ClothingImage.id == image_id))
    db_image = result.scalar_one_or_none()
    if not db_image:
        raise HTTPException(status_code=404, detail="Image not found")
        
    return Response(content=db_image.data, media_type=db_image.mime_type)

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
