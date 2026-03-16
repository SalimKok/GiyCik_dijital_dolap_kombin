from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.laundry_item import LaundryItem, LaundryStatusEnum
from app.schemas.laundry import LaundryItemCreate, LaundryItemUpdate

async def get_laundry_items(db: AsyncSession, user_id: int):
    stmt = select(LaundryItem).where(LaundryItem.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_laundry_item(db: AsyncSession, item_id: str, user_id: int):
    stmt = select(LaundryItem).where(LaundryItem.id == item_id, LaundryItem.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def get_laundry_item_by_clothing(db: AsyncSession, clothing_item_id: str, user_id: int):
    stmt = select(LaundryItem).where(LaundryItem.clothing_item_id == clothing_item_id, LaundryItem.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_laundry_item(db: AsyncSession, item_in: LaundryItemCreate, user_id: int):
    db_item = LaundryItem(
        id=item_in.id,
        user_id=user_id,
        clothing_item_id=item_in.clothing_item_id,
        name=item_in.name,
        category=item_in.category,
        wear_count=item_in.wear_count,
        max_wear=item_in.max_wear,
        icon_name=item_in.icon_name,
        status=LaundryStatusEnum(item_in.status)
    )
    db.add(db_item)
    await db.commit()
    await db.refresh(db_item)
    return db_item

async def update_laundry_item(db: AsyncSession, db_item: LaundryItem, item_update: LaundryItemUpdate):
    if item_update.wear_count is not None:
        db_item.wear_count = item_update.wear_count
    if item_update.max_wear is not None:
        db_item.max_wear = item_update.max_wear
    if item_update.status is not None:
        db_item.status = LaundryStatusEnum(item_update.status)
        
    db.add(db_item)
    await db.commit()
    await db.refresh(db_item)
    return db_item
