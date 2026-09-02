import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"
bot = telebot.TeleBot(BOT_TOKEN)

# KeyAuth Application Info
KEYAUTH_APP_NAME = "V4RTEXX MANAGER"
KEYAUTH_OWNER_ID = "pg6gDhL4a6"
KEYAUTH_SECRET = "1b6ae657e002b641129763f65920347345c9224bfdd1f514e7f8aa262886b03f"
KEYAUTH_VERSION = "1.0"

def build_welcome_markup():
    markup = InlineKeyboardMarkup(row_width=1)
    btn_channel = InlineKeyboardButton("📢 Join V4RTEXX Official Channel", url="https://t.me/v4rtexxofficial")
    btn_keyauth = InlineKeyboardButton("🔑 KeyAuth Dashboard", url="https://keyauth.win")
    markup.add(btn_channel, btn_keyauth)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *V4RTEXX MANAGER OFFICIAL BOT* ⚡\n\n"
        "🔐 *KeyAuth System Active*\n"
        f"• *App Name:* `{KEYAUTH_APP_NAME}`\n"
        f"• *Owner ID:* `{KEYAUTH_OWNER_ID}`\n"
        f"• *Version:* `{KEYAUTH_VERSION}`\n\n"
        "ℹ️ _License key generation and validation are managed directly via KeyAuth._\n\n"
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
    bot.answer_callback_query(call.id, "Use KeyAuth directly for license key management.")

if __name__ == "__main__":
    print(f"V4RTEXX Official Bot ({KEYAUTH_APP_NAME}) is running...")
    bot.infinity_polling()
