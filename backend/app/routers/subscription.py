from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.subscription import Subscription
from app.models.subscription import SubscriptionPlanEnum
from app.schemas.user import User
from app.services import subscription_service
from app.utils.deps import get_current_user

router = APIRouter()

@router.get("/", response_model=Subscription)
async def read_subscription(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Retrieve subscription for current user."""
    return await subscription_service.get_subscription(db, user_id=current_user.id)

@router.post("/purchase", response_model=Subscription)
async def purchase_plan(
    plan: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Mock purchase of a subscription plan."""
    try:
        plan_enum = SubscriptionPlanEnum(plan)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid plan name")
        
    return await subscription_service.purchase_plan(db, user_id=current_user.id, plan=plan_enum)

@router.post("/cancel", response_model=Subscription)
async def cancel_plan(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Cancel subscription plan."""
    return await subscription_service.cancel_plan(db, user_id=current_user.id)

@router.post("/increment-usage", response_model=Subscription)
async def increment_usage(
    metric: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """Increment arbitrary usage counters."""
    allowed_metrics = ["clothing_item_count", "outfit_count", "ai_usages_today", "calendar_event_count"]
    if metric not in allowed_metrics:
        raise HTTPException(status_code=400, detail=f"Invalid metric. Allowed: {allowed_metrics}")
        
    return await subscription_service.increment_usage(db, user_id=current_user.id, field_name=metric)
