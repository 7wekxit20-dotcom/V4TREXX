import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"
bot = telebot.TeleBot(BOT_TOKEN)

# V4RTEXX Auth System Info
APP_NAME = "V4RTEXX MANAGER"
AUTH_SYSTEM = "GitHub-Hosted V4RTEXX Auth"

def build_welcome_markup():
    markup = InlineKeyboardMarkup(row_width=1)
    btn_channel = InlineKeyboardButton("📢 Join V4RTEXX Official Channel", url="https://t.me/v4rtexxofficial")
    btn_repo = InlineKeyboardButton("🌐 GitHub Repository", url="https://github.com/7wekxit20-dotcom/V4TREXX")
    markup.add(btn_channel, btn_repo)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *V4RTEXX MANAGER OFFICIAL BOT* ⚡\n\n"
        "🔐 *V4RTEXX Auth System Active*\n"
        f"• *App Name:* `{APP_NAME}`\n"
        f"• *Auth Provider:* `{AUTH_SYSTEM}`\n\n"
        "ℹ️ _License key generation and validation are managed via your V4RTEXX Web Dashboard & GitHub._\n\n"
        "Join our official channel for announcements and updates!"
    )
    bot.send_message(
        message.chat.id,
        welcome_text,
        parse_mode="Markdown",
        reply_markup=build_welcome_markup()
    )

@bot.callback_query_handler(func=lambda call: True)
def callback_listener(call):
    bot.answer_callback_query(call.id, "License keys are managed via the V4RTEXX Web Dashboard.")

if __name__ == "__main__":
    print(f"V4RTEXX Official Bot ({APP_NAME}) is running...")
    bot.infinity_polling()
