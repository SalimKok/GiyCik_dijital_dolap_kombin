import os
import logging
from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)

class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    GEMINI_API_KEY: str = ""
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200

    class Config:
        env_file = ".env"

try:
    settings = Settings()
except Exception as e:
    # Fallback to defaults or environment vars if .env parsing fails or is missing
    settings = Settings(
        DATABASE_URL=os.environ.get("DATABASE_URL", "postgresql+asyncpg://postgres:password@localhost:5432/gircik"),
        SECRET_KEY=os.environ.get("SECRET_KEY", "fallback_secret_key_for_development_only"),
        GEMINI_API_KEY=os.environ.get("GEMINI_API_KEY", ""),
    )

# Fix Render/Supabase connection string for asyncpg
if settings.DATABASE_URL and settings.DATABASE_URL.startswith("postgresql://"):
    settings.DATABASE_URL = settings.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)
elif settings.DATABASE_URL and settings.DATABASE_URL.startswith("postgres://"):
    settings.DATABASE_URL = settings.DATABASE_URL.replace("postgres://", "postgresql+asyncpg://", 1)

# Startup diagnostics
logger.info(f"DATABASE_URL configured: {'Yes' if settings.DATABASE_URL else 'NO - MISSING!'}")
logger.info(f"SECRET_KEY configured: {'Yes' if settings.SECRET_KEY and settings.SECRET_KEY != 'fallback_secret_key_for_development_only' else 'WARNING - using fallback!'}")
logger.info(f"GEMINI_API_KEY configured: {'Yes' if settings.GEMINI_API_KEY else 'NO - AI features will be disabled!'}")

