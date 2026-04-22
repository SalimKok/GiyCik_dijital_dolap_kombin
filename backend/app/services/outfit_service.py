from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from app.models.outfit import Outfit, OutfitItemLink
from app.schemas.outfit import OutfitCreate, OutfitUpdate

async def get_outfits(db: AsyncSession, user_id: int):
    stmt = select(Outfit).where(Outfit.user_id == user_id).options(selectinload(Outfit.items)).order_by(Outfit.created_at.desc())
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_outfit(db: AsyncSession, outfit_id: str, user_id: int):
    stmt = select(Outfit).where(Outfit.id == outfit_id, Outfit.user_id == user_id).options(selectinload(Outfit.items))
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_outfit(db: AsyncSession, outfit_in: OutfitCreate, user_id: int):
    # Create main outfit
    db_outfit = Outfit(
        id=outfit_in.id,
        user_id=user_id,
        title=outfit_in.title,
        style=outfit_in.style,
        season=outfit_in.season,
        is_favorite=outfit_in.is_favorite
    )
    db.add(db_outfit)
    
    # Create items
    for idx, item in enumerate(outfit_in.items):
        db_item = OutfitItemLink(
            outfit_id=db_outfit.id,
            clothing_item_id=item.clothing_item_id,
            name=item.name,
            icon_name=item.icon_name,
            display_order=idx
        )
        db.add(db_item)

    await db.commit()
    await db.refresh(db_outfit)
    return await get_outfit(db, outfit_in.id, user_id) # reload with relationships

async def update_outfit(db: AsyncSession, db_outfit: Outfit, outfit_update: OutfitUpdate):
    update_data = outfit_update.model_dump(exclude_unset=True)
    
    items_data = update_data.pop("items", None)

    for key, value in update_data.items():
        setattr(db_outfit, key, value)
    
    if items_data is not None:
        # Clear old items via ORM relationship (avoids session state conflicts)
        db_outfit.items.clear()
        await db.flush()
        
        # Create new items
        for idx, item in enumerate(items_data):
            db_item = OutfitItemLink(
                outfit_id=db_outfit.id,
                clothing_item_id=item['clothing_item_id'],
                name=item['name'],
                icon_name=item.get('icon_name'),
                display_order=idx
            )
            db_outfit.items.append(db_item)

    await db.commit()
    
    # Reload with relationships
    return await get_outfit(db, db_outfit.id, db_outfit.user_id)

async def toggle_favorite(db: AsyncSession, outfit_id: str, user_id: int):
    outfit = await get_outfit(db, outfit_id, user_id)
    if outfit:
        outfit.is_favorite = not outfit.is_favorite
        db.add(outfit)
        await db.commit()
        await db.refresh(outfit)
    return outfit

async def delete_outfit(db: AsyncSession, outfit_id: str, user_id: int):
    stmt = delete(Outfit).where(Outfit.id == outfit_id, Outfit.user_id == user_id)
    await db.execute(stmt)
    await db.commit()
    return True
