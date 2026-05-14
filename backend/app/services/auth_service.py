from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.utils.security import get_password_hash

async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
    hashed_password = get_password_hash(user_in.password)
    db_user = User(
        name=user_in.name,
        email=user_in.email,
        hashed_password=hashed_password
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def update_user(db: AsyncSession, db_user: User, user_in: UserUpdate) -> User:
    if user_in.name is not None:
        db_user.name = user_in.name
    if user_in.email is not None:
        db_user.email = user_in.email
    if user_in.password is not None:
        db_user.hashed_password = get_password_hash(user_in.password)
    
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def update_fcm_token(db: AsyncSession, db_user: User, token: str) -> User:
    db_user.fcm_token = token
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def delete_user(db: AsyncSession, db_user: User) -> bool:
    await db.delete(db_user)
    await db.commit()
    return True

import random
from datetime import datetime, timezone, timedelta
from app.models.user import PasswordReset

async def create_password_reset_code(db: AsyncSession, email: str) -> str:
    # Delete any existing codes for this email
    stmt = select(PasswordReset).where(PasswordReset.email == email)
    result = await db.execute(stmt)
    existing_codes = result.scalars().all()
    for code in existing_codes:
        await db.delete(code)
    
    # Generate 6 digit random code
    code = f"{random.randint(100000, 999999)}"
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=15)
    
    reset_entry = PasswordReset(
        email=email,
        code=code,
        expires_at=expires_at
    )
    db.add(reset_entry)
    await db.commit()
    
    return code

async def verify_reset_code_and_update_password(db: AsyncSession, email: str, code: str, new_password: str) -> bool:
    # Find valid code
    stmt = select(PasswordReset).where(
        PasswordReset.email == email,
        PasswordReset.code == code,
    )
    result = await db.execute(stmt)
    reset_entry = result.scalar_one_or_none()
    
    if not reset_entry:
        return False
        
    if reset_entry.expires_at.replace(tzinfo=timezone.utc) < datetime.now(timezone.utc):
        await db.delete(reset_entry)
        await db.commit()
        return False
        
    # Update password
    user = await get_user_by_email(db, email)
    if not user:
        return False
        
    user.hashed_password = get_password_hash(new_password)
    db.add(user)
    
    # Delete used code
    await db.delete(reset_entry)
    await db.commit()
    return True
