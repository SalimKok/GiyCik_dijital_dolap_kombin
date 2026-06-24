from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from app.config import settings

# Production-ready engine configuration
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=not settings.is_production,  # Disable SQL logging in production
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,  # Verify connections before using them
    pool_recycle=300,     # Recycle connections every 5 minutes
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

Base = declarative_base()

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session
