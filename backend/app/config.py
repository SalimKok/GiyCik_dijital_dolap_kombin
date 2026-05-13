import os
from pydantic_settings import BaseSettings

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
