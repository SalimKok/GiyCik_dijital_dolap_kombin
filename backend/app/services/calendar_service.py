from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.models.calendar_event import CalendarEvent
from app.schemas.calendar import CalendarEventCreate, CalendarEventUpdate

async def get_events(db: AsyncSession, user_id: int):
    stmt = select(CalendarEvent).where(CalendarEvent.user_id == user_id).order_by(CalendarEvent.date.asc())
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_event(db: AsyncSession, event_id: str, user_id: int):
    stmt = select(CalendarEvent).where(CalendarEvent.id == event_id, CalendarEvent.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_event(db: AsyncSession, event_in: CalendarEventCreate, user_id: int):
    db_event = CalendarEvent(
        id=event_in.id,
        user_id=user_id,
        date=event_in.date,
        title=event_in.title,
        outfit_id=event_in.outfit_id
    )
    db.add(db_event)
    await db.commit()
    await db.refresh(db_event)
    return db_event

async def update_event(db: AsyncSession, db_event: CalendarEvent, event_update: CalendarEventUpdate):
    update_data = event_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_event, key, value)
    
    db.add(db_event)
    await db.commit()
    await db.refresh(db_event)
    return db_event

async def delete_event(db: AsyncSession, event_id: str, user_id: int):
    stmt = delete(CalendarEvent).where(CalendarEvent.id == event_id, CalendarEvent.user_id == user_id)
    await db.execute(stmt)
    await db.commit()
    return True
