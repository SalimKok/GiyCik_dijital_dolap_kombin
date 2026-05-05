from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.models.laundry_item import LaundryItem, LaundryStatusEnum
from app.schemas.laundry import LaundryItemCreate, LaundryItemUpdate

async def get_laundry_items(db: AsyncSession, user_id: int):
    stmt = select(LaundryItem).where(LaundryItem.user_id == user_id).options(selectinload(LaundryItem.clothing_item))
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_laundry_item(db: AsyncSession, item_id: str, user_id: int):
    stmt = select(LaundryItem).where(LaundryItem.id == item_id, LaundryItem.user_id == user_id).options(selectinload(LaundryItem.clothing_item))
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

async def ensure_laundry_for_user(db: AsyncSession, user_id: int):
    """Create laundry records for clothing items that don't have one yet."""
    from app.models.clothing_item import ClothingItem
    import uuid
    
    # Get all clothing items for user
    stmt = select(ClothingItem).where(ClothingItem.user_id == user_id)
    result = await db.execute(stmt)
    all_clothes = result.scalars().all()
    
    # Get existing laundry records
    stmt2 = select(LaundryItem.clothing_item_id).where(LaundryItem.user_id == user_id)
    result2 = await db.execute(stmt2)
    existing_ids = set(result2.scalars().all())
    
    created = 0
    skipped_categories = ["Şal/Eşarp", "Ayakkabı", "Aksesuar"]
    
    # Kullanıcının mevcut max_wear tercihini oku (varsa)
    stmt_pref = select(LaundryItem.max_wear).where(LaundryItem.user_id == user_id).limit(1)
    result_pref = await db.execute(stmt_pref)
    user_max_wear = result_pref.scalar_one_or_none() or 3
    
    for cloth in all_clothes:
        if cloth.id not in existing_ids and cloth.category not in skipped_categories:
            db_item = LaundryItem(
                id=str(uuid.uuid4()),
                user_id=user_id,
                clothing_item_id=cloth.id,
                name=cloth.name,
                category=cloth.category,
                wear_count=0,
                max_wear=user_max_wear,
                icon_name='checkroom',
                status=LaundryStatusEnum.clean
            )
            db.add(db_item)
            created += 1
    
    # Clean up: Remove any existing laundry records for these categories that might have been created before
    from app.models.laundry_item import LaundryItem as LaundryItemModel
    from sqlalchemy import delete
    
    stmt3 = delete(LaundryItemModel).where(
        LaundryItemModel.user_id == user_id,
        LaundryItemModel.category.in_(skipped_categories)
    )
    await db.execute(stmt3)
    await db.commit()
    
    return created

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

async def update_all_max_wear(db: AsyncSession, user_id: int, max_wear: int):
    from sqlalchemy import update
    stmt = update(LaundryItem).where(LaundryItem.user_id == user_id).values(max_wear=max_wear)
    await db.execute(stmt)
    await db.commit()
    return True

