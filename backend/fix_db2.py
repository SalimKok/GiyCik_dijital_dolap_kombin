import asyncio
import sys
import os

from sqlalchemy import text
from app.database import engine

async def fix():
    async with engine.begin() as conn:
        try:
            await conn.execute(text("ALTER TABLE clothing_items ADD COLUMN season VARCHAR(50)"))
            print("Column season added successfully!")
        except Exception as e:
            print("Error season:", e)

if __name__ == "__main__":
    asyncio.run(fix())
