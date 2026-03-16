from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.models.clothing_item import ClothingItem
from app.schemas.clothing import ClothingItemCreate, ClothingItemUpdate
from app.models.user import User

async def get_clothing_items(db: AsyncSession, user_id: int):
    stmt = select(ClothingItem).where(ClothingItem.user_id == user_id).order_by(ClothingItem.created_at.desc())
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_clothing_item(db: AsyncSession, item_id: str, user_id: int):
    stmt = select(ClothingItem).where(ClothingItem.id == item_id, ClothingItem.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_clothing_item(db: AsyncSession, item_in: ClothingItemCreate, user_id: int):
    db_item = ClothingItem(
        id=item_in.id,
        user_id=user_id,
        name=item_in.name,
        category=item_in.category,
        color=item_in.color
    )
    db.add(db_item)
    await db.commit()
    await db.refresh(db_item)
    return db_item

async def update_clothing_item(db: AsyncSession, db_item: ClothingItem, item_update: ClothingItemUpdate):
    update_data = item_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_item, key, value)
    
    db.add(db_item)
    await db.commit()
    await db.refresh(db_item)
    return db_item

async def delete_clothing_item(db: AsyncSession, item_id: str, user_id: int):
    stmt = delete(ClothingItem).where(ClothingItem.id == item_id, ClothingItem.user_id == user_id)
    await db.execute(stmt)
    await db.commit()
    return True
