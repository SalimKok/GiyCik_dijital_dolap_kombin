from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.database import engine, Base
from app.routers import auth, clothing, outfits, laundry, calendar, subscription

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Depending on alembic setup, we might skip creating tables here and use Alembic instead. 
    # For development without alembic, we can uncomment the following:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()

app = FastAPI(
    title="GiyÇık API",
    description="Backend API for GiyÇık Wardrobe & Style Assistant",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(clothing.router, prefix="/api/clothing", tags=["Clothing Items"])
app.include_router(outfits.router, prefix="/api/outfits", tags=["Outfits"])
app.include_router(laundry.router, prefix="/api/laundry", tags=["Laundry"])
app.include_router(calendar.router, prefix="/api/calendar", tags=["Calendar Events"])
app.include_router(subscription.router, prefix="/api/subscription", tags=["Subscription"])

@app.get("/")
async def root():
    return {"message": "Welcome to GiyÇık API"}
