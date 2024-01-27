from telegram.ext import Application
import os

# Initialize the Telegram Bot
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
CHAT_ID = os.getenv('CHAT_ID')
application = Application.builder().token(TELEGRAM_TOKEN).build()


async def send_alert_message(name, lat, lon, number):
    message = f"<b>{name}</b> нажал(а) кнопку SOS 🆘\n<b>Номер телефона:</b> {number}\nЛокация👇"

    await application.bot.send_message(chat_id=CHAT_ID, text=message, parse_mode='HTML')
    await application.bot.send_location(chat_id=CHAT_ID, latitude=lat, longitude=lon)
