from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.database import get_db
from app.schemas.outfit import Outfit, OutfitCreate, OutfitUpdate
from app.schemas.user import User
from app.services import outfit_service
from app.utils.deps import get_current_user

router = APIRouter()

@router.get("/", response_model=List[Outfit])
async def read_outfits(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Retrieve all outfits for current user."""
    outfits = await outfit_service.get_outfits(db, user_id=current_user.id)
    return outfits

class OutfitGenerateRequest(BaseModel):
    season: str
    weather: str
    event: str
    style: str

@router.post("/generate", response_model=dict)
async def generate_outfit_recommendation(
    request: OutfitGenerateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Generate an outfit recommendation using AI."""
    from app.services import clothing_service, vision_service
    clothes = await clothing_service.get_clothing_items(db, user_id=current_user.id)
    
    wardrobe = []
    for c in clothes:
        wardrobe.append({"id": c.id, "name": c.name, "category": c.category, "color": c.color})

    if not wardrobe:
        raise HTTPException(status_code=400, detail="Gardırobunuzda hiç eşya yok. Lütfen kombin önerisi almadan önce kıyafet ekleyin.")

    result = vision_service.generate_outfit(wardrobe, request.season, request.weather, request.event, request.style)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    elif not result:
        raise HTTPException(status_code=500, detail="Yapay Zeka uyumlu bir kombin öneremedi. Daha fazla kıyafet eklemeyi deneyebilirsiniz.")
    return result

@router.post("/", response_model=Outfit)
async def create_outfit(
    outfit_in: OutfitCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Create new outfit."""
    existing_outfit = await outfit_service.get_outfit(db, outfit_id=outfit_in.id, user_id=current_user.id)
    if existing_outfit:
        raise HTTPException(status_code=400, detail="Outfit with this ID already exists")

    return await outfit_service.create_outfit(db, outfit_in=outfit_in, user_id=current_user.id)

@router.get("/{outfit_id}", response_model=Outfit)
async def read_outfit(
    outfit_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Get single outfit."""
    outfit = await outfit_service.get_outfit(db, outfit_id=outfit_id, user_id=current_user.id)
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit not found")
    return outfit

@router.put("/{outfit_id}", response_model=Outfit)
async def update_outfit(
    outfit_id: str,
    outfit_update: OutfitUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Update an outfit (title, style, season etc)."""
    outfit = await outfit_service.get_outfit(db, outfit_id=outfit_id, user_id=current_user.id)
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit not found")
    return await outfit_service.update_outfit(db, db_outfit=outfit, outfit_update=outfit_update)

@router.patch("/{outfit_id}/favorite", response_model=Outfit)
async def toggle_favorite(
    outfit_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Toggle outfit favorite status."""
    outfit = await outfit_service.toggle_favorite(db, outfit_id=outfit_id, user_id=current_user.id)
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit not found")
    return outfit

@router.delete("/{outfit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_outfit(
    outfit_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Delete an outfit."""
    outfit = await outfit_service.get_outfit(db, outfit_id=outfit_id, user_id=current_user.id)
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit not found")
    await outfit_service.delete_outfit(db, outfit_id=outfit_id, user_id=current_user.id)
    return None
