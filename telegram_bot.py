import requests
import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton
import random
import string
import json
import os

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"
bot = telebot.TeleBot(BOT_TOKEN)

# In-memory / file-backed key database
DB_FILE = "keys_db.json"

def load_keys():
    if os.path.exists(DB_FILE):
        try:
            with open(DB_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_keys(keys_data):
    try:
        with open(DB_FILE, "w") as f:
            json.dump(keys_data, f, indent=2)
    except Exception as e:
        print(f"Error saving keys: {e}")

keys_db = load_keys()

# User pending generation state
user_state = {}

def generate_key_string():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(19))

def build_main_menu():
    markup = InlineKeyboardMarkup(row_width=1)
    btn_key = InlineKeyboardButton("🔑 Generate Key", callback_data="start_gen")
    btn_status = InlineKeyboardButton("ℹ️ Manage & Revoke Keys", callback_data="manage_keys")
    markup.add(btn_key, btn_status)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *V4RTEXX MANAGER License Key Generator* ⚡\n\n"
        "Generate & manage customized license keys for V4RTEXX MANAGER iOS App."
    )
    bot.send_message(
        message.chat.id,
        welcome_text,
        parse_mode="Markdown",
        reply_markup=build_main_menu()
    )

@bot.callback_query_handler(func=lambda call: True)
def callback_listener(call):
    chat_id = call.message.chat.id
    msg_id = call.message.message_id
    data = call.data

    if data == "main_menu":
        user_state.pop(chat_id, None)
        welcome_text = (
            "⚡ *V4RTEXX MANAGER License Key Generator* ⚡\n\n"
            "Generate & manage customized license keys for V4RTEXX MANAGER iOS App."
        )
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text=welcome_text,
            parse_mode="Markdown",
            reply_markup=build_main_menu()
        )

    elif data == "start_gen":
        # Step 1: Select Duration
        user_state[chat_id] = {}
        markup = InlineKeyboardMarkup(row_width=2)
        btn1 = InlineKeyboardButton("⏳ 1 Day", callback_data="dur_1d")
        btn7 = InlineKeyboardButton("📅 7 Days", callback_data="dur_7d")
        btn30 = InlineKeyboardButton("📆 30 Days", callback_data="dur_30d")
        btn_life = InlineKeyboardButton("♾️ Lifetime", callback_data="dur_life")
        btn_back = InlineKeyboardButton("🔙 Back", callback_data="main_menu")
        markup.add(btn1, btn7)
        markup.add(btn30, btn_life)
        markup.add(btn_back)
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text="⏱️ *Step 1: Select Key Duration*",
            parse_mode="Markdown",
            reply_markup=markup
        )

    elif data.startswith("dur_"):
        duration_map = {
            "dur_1d": "1 Day",
            "dur_7d": "7 Days",
            "dur_30d": "30 Days",
            "dur_life": "Lifetime"
        }
        chosen_dur = duration_map.get(data, "Lifetime")
        user_state[chat_id] = {"duration": chosen_dur}

        # Step 2: Select Device Binding / Global Scope
        markup = InlineKeyboardMarkup(row_width=1)
        btn_single = InlineKeyboardButton("📱 1 Device (Bound)", callback_data="scope_single")
        btn_global = InlineKeyboardButton("🌐 Global Key (All Devices)", callback_data="scope_global")
        btn_back = InlineKeyboardButton("🔙 Back", callback_data="start_gen")
        markup.add(btn_single, btn_global, btn_back)
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text=f"📱 *Step 2: Select Device Scope*\nSelected Duration: `{chosen_dur}`",
            parse_mode="Markdown",
            reply_markup=markup
        )

    elif data.startswith("scope_"):
        scope_map = {
            "scope_single": "1 Device (Bound)",
            "scope_global": "Global (All Devices)"
        }
        chosen_scope = scope_map.get(data, "Global (All Devices)")
        state = user_state.get(chat_id, {"duration": "Lifetime"})
        duration = state.get("duration", "Lifetime")

        # Generate Key
        key_str = generate_key_string()
        keys_db[key_str] = {
            "duration": duration,
            "scope": chosen_scope,
            "status": "Active",
            "owner": str(chat_id)
        }
        save_keys(keys_db)

        result_text = (
            "✅ *V4RTEXX LICENSE KEY GENERATED*\n\n"
            f"`{key_str}`\n\n"
            f"⏱️ *Duration:* {duration}\n"
            f"🌐 *Scope:* {chosen_scope}\n\n"
            "📋 _Tap key above to copy, then paste it in V4RTEXX MANAGER app._"
        )
        markup = InlineKeyboardMarkup(row_width=1)
        btn_gen_another = InlineKeyboardButton("🔄 Generate Another Key", callback_data="start_gen")
        btn_menu = InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu")
        markup.add(btn_gen_another, btn_menu)
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text=result_text,
            parse_mode="Markdown",
            reply_markup=markup
        )

    elif data == "manage_keys":
        owner_keys = {k: v for k, v in keys_db.items() if v.get("owner") == str(chat_id) and v.get("status") == "Active"}
        if not owner_keys:
            text = "ℹ️ *Key Status & Revocation*\n\nYou currently have no active generated keys."
            markup = InlineKeyboardMarkup()
            markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=text, parse_mode="Markdown", reply_markup=markup)
            return

        text = f"ℹ️ *Active Keys ({len(owner_keys)})*\nSelect a key to revoke or remove:"
        markup = InlineKeyboardMarkup(row_width=1)
        for key_str, info in list(owner_keys.items())[:10]:
            btn_label = f"❌ Revoke: {key_str} ({info.get('duration')})"
            markup.add(InlineKeyboardButton(btn_label, callback_data=f"revoke_{key_str}"))
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=text, parse_mode="Markdown", reply_markup=markup)

    elif data.startswith("revoke_"):
        key_to_revoke = data.replace("revoke_", "")
        if key_to_revoke in keys_db:
            keys_db[key_to_revoke]["status"] = "Revoked"
            save_keys(keys_db)
            revoked_text = f"🗑️ *Key Revoked & Removed*\n\nKey `{key_to_revoke}` has been revoked."
        else:
            revoked_text = "⚠️ Key not found."

        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=revoked_text, parse_mode="Markdown", reply_markup=markup)

if __name__ == "__main__":
    print("V4RTEXX Telegram Bot is running...")
    bot.infinity_polling()
