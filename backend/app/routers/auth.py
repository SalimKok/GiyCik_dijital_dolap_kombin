from datetime import timedelta
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.user import User, UserCreate, UserUpdate
from app.schemas.token import Token
from app.services import auth_service
from app.utils.security import verify_password, create_access_token
from app.utils.deps import get_current_user

router = APIRouter()

@router.post("/register", response_model=User)
async def register(
    user_in: UserCreate, 
    db: Annotated[AsyncSession, Depends(get_db)]
):
    user = await auth_service.get_user_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this user name already exists in the system.",
        )
    user = await auth_service.create_user(db, user_in=user_in)
    return user

@router.post("/login", response_model=Token)
async def login_access_token(
    db: Annotated[AsyncSession, Depends(get_db)],
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
) -> Token:
    """OAuth2 compatible token login, get an access token for future requests"""
    user = await auth_service.get_user_by_email(db, email=form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(subject=user.id)
    return Token(access_token=access_token, token_type="bearer")

@router.get("/me", response_model=User)
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    return current_user

@router.put("/me", response_model=User)
async def update_user_me(
    user_in: UserUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    return await auth_service.update_user(db, db_user=current_user, user_in=user_in)

@router.delete("/me")
async def delete_user_me(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)]
) -> dict:
    await auth_service.delete_user(db, db_user=current_user)
    return {"status": "success"}
