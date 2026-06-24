import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
from app.config import settings
from app.database import engine, Base
from app.routers import auth, clothing, outfits, laundry, calendar, subscription, travel
from app.services import notification_service

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Start the notification scheduler
    notification_service.start_scheduler()

    yield
    await engine.dispose()

app = FastAPI(
    title="GiyÇık API",
    description="Backend API for GiyÇık Wardrobe & Style Assistant",
    version="1.0.0",
    lifespan=lifespan,
    # Disable interactive docs in production for security
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
)

# --- Middleware ---

# CORS — restrict origins in production
_allowed_origins = ["*"] if not settings.is_production else [
    "https://giycik.com",
    "https://www.giycik.com",
    "https://giycik-api.onrender.com",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if settings.is_production:
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["giycik-api.onrender.com", "*.onrender.com"],
    )

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(clothing.router, prefix="/api/clothing", tags=["Clothing Items"])
app.include_router(outfits.router, prefix="/api/outfits", tags=["Outfits"])
app.include_router(laundry.router, prefix="/api/laundry", tags=["Laundry"])
app.include_router(calendar.router, prefix="/api/calendar", tags=["Calendar Events"])
app.include_router(subscription.router, prefix="/api/subscription", tags=["Subscription"])
app.include_router(travel.router, prefix="/api/travel", tags=["Travel Plans"])


@app.get("/")
async def root():
    return {"message": "Welcome to GiyÇık API"}


@app.get("/health")
async def health_check():
    """Health check endpoint for Render and keep-alive cron jobs."""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "database": "configured" if settings.DATABASE_URL else "missing",
        "gemini_ai": "configured" if settings.GEMINI_API_KEY else "not configured",
    }
