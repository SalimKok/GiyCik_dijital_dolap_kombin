from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.subscription import Subscription, SubscriptionPlanEnum
from app.schemas.subscription import SubscriptionUpdate

async def get_subscription(db: AsyncSession, user_id: int):
    stmt = select(Subscription).where(Subscription.user_id == user_id)
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    
    # Auto-create default free subscription if missing
    if not sub:
        sub = Subscription(user_id=user_id, plan=SubscriptionPlanEnum.free)
        db.add(sub)
        await db.commit()
        await db.refresh(sub)
    return sub

async def purchase_plan(db: AsyncSession, user_id: int, plan: SubscriptionPlanEnum):
    sub = await get_subscription(db, user_id)
    sub.plan = plan
    sub.started_at = datetime.now(timezone.utc)
    
    if plan == SubscriptionPlanEnum.monthly:
        sub.expires_at = datetime.now(timezone.utc) + timedelta(days=30)
    elif plan == SubscriptionPlanEnum.yearly:
        sub.expires_at = datetime.now(timezone.utc) + timedelta(days=365)
    else:
        sub.expires_at = None
        
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub

async def cancel_plan(db: AsyncSession, user_id: int):
    sub = await get_subscription(db, user_id)
    sub.plan = SubscriptionPlanEnum.free
    sub.expires_at = None
    
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub
    
async def increment_usage(db: AsyncSession, user_id: int, field_name: str):
    sub = await get_subscription(db, user_id)
    current_val = getattr(sub, field_name, 0)
    setattr(sub, field_name, current_val + 1)
    
    # Reset AI usage daily
    if field_name == "ai_usages_today":
        today = datetime.now(timezone.utc).date()
        if sub.last_ai_usage_date != today:
            sub.ai_usages_today = 1
            sub.last_ai_usage_date = today

    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub
