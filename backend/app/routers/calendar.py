from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.calendar import CalendarEvent, CalendarEventCreate, CalendarEventUpdate
from app.schemas.user import User
from app.services import calendar_service
from app.utils.deps import get_current_user

router = APIRouter()

@router.get("/", response_model=List[CalendarEvent])
async def read_events(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Retrieve all calendar events for current user."""
    events = await calendar_service.get_events(db, user_id=current_user.id)
    return events

@router.post("/", response_model=CalendarEvent)
async def create_event(
    event_in: CalendarEventCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Create new calendar event."""
    existing_event = await calendar_service.get_event(db, event_id=event_in.id, user_id=current_user.id)
    if existing_event:
        raise HTTPException(status_code=400, detail="Event with this ID already exists")

    return await calendar_service.create_event(db, event_in=event_in, user_id=current_user.id)

@router.put("/{event_id}", response_model=CalendarEvent)
async def update_event(
    event_id: str,
    event_update: CalendarEventUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Update a calendar event."""
    event = await calendar_service.get_event(db, event_id=event_id, user_id=current_user.id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return await calendar_service.update_event(db, db_event=event, event_update=event_update)

@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event(
    event_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Delete a calendar event."""
    event = await calendar_service.get_event(db, event_id=event_id, user_id=current_user.id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    await calendar_service.delete_event(db, event_id=event_id, user_id=current_user.id)
    return None
