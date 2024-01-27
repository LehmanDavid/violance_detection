from telegram.ext import Application
import os

# Initialize the Telegram Bot
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
CHAT_ID = os.getenv('CHAT_ID')
application = Application.builder().token(TELEGRAM_TOKEN).build()

async def send_alert_message(name, lat, lon):
    message = f"{name} need a help!"
    
    print(message)
    await application.bot.send_message(chat_id=CHAT_ID, text=message)
    await application.bot.send_location(chat_id=CHAT_ID, latitude=lat, longitude=lon)

