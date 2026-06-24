import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    GEMINI_API_KEY: str = ""
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200

    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""

    ENVIRONMENT: str = "development"

    class Config:
        env_file = ".env"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"


def _load_settings() -> Settings:
    """Load settings from .env file or environment variables with a safe fallback."""
    try:
        return Settings()
    except Exception:
        return Settings(
            DATABASE_URL=os.environ.get(
                "DATABASE_URL",
                "postgresql+asyncpg://postgres:password@localhost:5432/gircik",
            ),
            SECRET_KEY=os.environ.get(
                "SECRET_KEY", "fallback_secret_key_for_development_only"
            ),
            GEMINI_API_KEY=os.environ.get("GEMINI_API_KEY", ""),
        )


settings = _load_settings()
