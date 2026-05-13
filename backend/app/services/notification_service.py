import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta, timezone

from app.database import AsyncSessionLocal
from app.models.user import User
from app.models.clothing_item import ClothingItem
from app.models.subscription import Subscription

logger = logging.getLogger(__name__)

# Mock initialization of Firebase (In a real app, you need a valid JSON key)
try:
    if not firebase_admin._apps:
         # JSON dosyasının yolunu belirtin
        cred = credentials.Certificate('firebase_credentials.json')
        firebase_admin.initialize_app(cred)
        logger.info("Firebase başarıyla başlatıldı.")
except Exception as e:
    logger.warning(f"Firebase not fully initialized: {e}")

def send_push_notification(token: str, title: str, body: str, data: dict = None):
    """Sends a push notification via Firebase."""
    if not token:
        return
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data=data or {},
            token=token,
        )
        # Uncomment in production with valid credentials:
        response = messaging.send(message)
        logger.info(f"Successfully sent message: {response}")
    except Exception as e:
        logger.error(f"Error sending FCM message: {e}")

async def run_daily_morning_routine():
    """Runs every day at 08:00 AM for Daily Outfit AI"""
    logger.info("Running Daily Morning Routine (AI Outfits)...")
    async with AsyncSessionLocal() as db:
        # Fetch all users
        result = await db.execute(select(User))
        users = result.scalars().all()
        
        now = datetime.now(timezone.utc)
        
        for user in users:
            if not user.fcm_token:
                continue
            
            # Check subscription
            # Free users get it only if within 7 days of signup
            sub_res = await db.execute(select(Subscription).where(Subscription.user_id == user.id))
            subscription = sub_res.scalar_one_or_none()
            
            is_pro = subscription.is_pro if subscription else False
            is_new_user = (now - user.created_at).days <= 7
            
            if is_pro or is_new_user:
                # Simulate AI logic / Weather check
                title = "Günaydın! ☀️ Bugün hava yağmurlu."
                body = "Senin için harika bir kombin hazırladım, göz atmaya ne dersin?"
                send_push_notification(user.fcm_token, title, body)


async def run_hygiene_reminders():
    """Runs daily to check for items that have been in laundry for 7 days"""
    logger.info("Running Hygiene Reminders (1 Week in Laundry)...")
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(User))
        users = result.scalars().all()
        
        # Here we would fetch Laundry items older than 7 days
        # For mock purposes:
        for user in users:
            if user.fcm_token:
                # Assuming user has old dirty clothes
                title = "Kirli sepetin dolmuş olabilir! 🫧"
                body = "Kirli sepetinde 1 haftadır bekleyen kıyafetlerin var. Yıkama günü gelmiş olabilir mi?"
                # send_push_notification(user.fcm_token, title, body)
                logger.info(f"Checked hygiene for user {user.id}")

async def run_monthly_forgotten_items():
    """Runs at the end of the month to remind about forgotten items"""
    logger.info("Running Monthly Forgotten Items Check...")
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(User))
        users = result.scalars().all()
        for user in users:
            if user.fcm_token:
                title = "Gardırobunun diplerinde bir şeyler var!"
                body = "Bazı kıyafetlerini bu ay hiç giymedin. Önümüzdeki ay onlara bir şans vermeye ne dersin?"
                # send_push_notification(user.fcm_token, title, body)
                logger.info(f"Checked forgotten items for user {user.id}")

def start_scheduler():
    scheduler = AsyncIOScheduler()
    
    # 1. Daily outfit (Every day at 08:00)
    scheduler.add_job(run_daily_morning_routine, 'cron', hour=8, minute=0)
    
    # 2. Hygiene Reminder (Every day at 19:00)
    scheduler.add_job(run_hygiene_reminders, 'cron', hour=19, minute=0)
    
    # 3. Monthly Forgotten Items (Last day of the month)
    # APScheduler supports 'last' for day to mean last day of month
    scheduler.add_job(run_monthly_forgotten_items, 'cron', day='last', hour=18, minute=0)

    scheduler.start()
    logger.info("Notification Scheduler Started")
