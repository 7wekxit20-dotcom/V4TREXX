import Foundation
import requests
import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton
import random
import string

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"

bot = telebot.TeleBot(BOT_TOKEN)

def generate_key():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(19))

def build_main_menu():
    markup = InlineKeyboardMarkup(row_width=2)
    btn_key = InlineKeyboardButton("🔑 Generate Key", callback_data="gen_key")
    btn_info = InlineKeyboardButton("ℹ️ Key Status", callback_data="key_status")
    btn_help = InlineKeyboardButton("❓ Help", callback_data="help")
    btn_channel = InlineKeyboardButton("📢 Join Channel", url="https://t.me/V4RTEXX")
    markup.add(btn_key, btn_info)
    markup.add(btn_help, btn_channel)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *Welcome to V4RTEXX MANAGER License Bot* ⚡\n\n"
        "Generate license keys for V4RTEXX MANAGER iOS App.\n"
        "Click the buttons below to interact with the bot."
    )
    bot.send_message(
        message.chat.id,
        welcome_text,
        parse_mode="Markdown",
        reply_markup=build_main_menu()
    )

@bot.callback_query_handler(func=lambda call: True)
def callback_listener(call):
    if call.data == "gen_key":
        new_key = generate_key()
        key_text = (
            "✅ *V4RTEXX LICENSE KEY GENERATED*\n\n"
            f"`{new_key}`\n\n"
            "📋 _Tap key above to copy, then paste it in V4RTEXX MANAGER app._"
        )
        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("🔄 Generate Another Key", callback_data="gen_key"))
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=key_text,
            parse_mode="Markdown",
            reply_markup=markup
        )
    elif call.data == "key_status":
        status_text = (
            "ℹ️ *Key System Status*\n\n"
            "• Server Status: 🟢 Online\n"
            "• Key Length: 19 Characters\n"
            "• Format: Alphanumeric\n"
            "• Supported Apps: V4RTEXX MANAGER (iOS)"
        )
        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=status_text,
            parse_mode="Markdown",
            reply_markup=markup
        )
    elif call.data == "help":
        help_text = (
            "❓ *How to Activate V4RTEXX MANAGER*\n\n"
            "1. Click *🔑 Generate Key* button.\n"
            "2. Copy the 19-character key.\n"
            "3. Open V4RTEXX MANAGER on your iOS device.\n"
            "4. Tap *Paste* and press *Activate V4RTEXX*."
        )
        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=help_text,
            parse_mode="Markdown",
            reply_markup=markup
        )
    elif call.data == "main_menu":
        welcome_text = (
            "⚡ *Welcome to V4RTEXX MANAGER License Bot* ⚡\n\n"
            "Generate license keys for V4RTEXX MANAGER iOS App.\n"
            "Click the buttons below to interact with the bot."
        )
        bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=welcome_text,
            parse_mode="Markdown",
            reply_markup=build_main_menu()
        )

if __name__ == "__main__":
    print("V4RTEXX Telegram Bot is running...")
    bot.infinity_polling()
