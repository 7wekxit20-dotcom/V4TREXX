import requests
import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton
import random
import string
import json
import os

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"
bot = telebot.TeleBot(BOT_TOKEN)

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
user_state = {}

def generate_key_string():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(19))

def build_main_menu():
    markup = InlineKeyboardMarkup(row_width=1)
    btn_key = InlineKeyboardButton("🔑 Generate Key", callback_data="start_gen")
    btn_status = InlineKeyboardButton("ℹ️ Key Status & Bound Devices", callback_data="manage_keys")
    markup.add(btn_key, btn_status)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *V4RTEXX MANAGER License Key Generator* ⚡\n\n"
        "Generate & manage customized license keys with Device UUID binding."
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
            "Generate & manage customized license keys with Device UUID binding."
        )
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text=welcome_text,
            parse_mode="Markdown",
            reply_markup=build_main_menu()
        )

    elif data == "start_gen":
        # Step 1: Duration Selection
        user_state[chat_id] = {}
        markup = InlineKeyboardMarkup(row_width=2)
        btn1 = InlineKeyboardButton("⏳ 1 Day", callback_data="dur_1d")
        btn7 = InlineKeyboardButton("📅 7 Days", callback_data="dur_7d")
        btn30 = InlineKeyboardButton("📆 30 Days", callback_data="dur_30d")
        btn_life = InlineKeyboardButton("♾️ Lifetime", callback_data="dur_life")
        btn_custom = InlineKeyboardButton("✏️ Manual Custom Duration", callback_data="dur_custom")
        btn_back = InlineKeyboardButton("🔙 Back", callback_data="main_menu")
        markup.add(btn1, btn7)
        markup.add(btn30, btn_life)
        markup.add(btn_custom)
        markup.add(btn_back)
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text="⏱️ *Step 1: Select Key Duration*",
            parse_mode="Markdown",
            reply_markup=markup
        )

    elif data == "dur_custom":
        msg = bot.send_message(chat_id, "✏️ *Please reply with your custom duration* (e.g., `15 Days`, `60 Days`):", parse_mode="Markdown")
        bot.register_next_step_handler(msg, process_custom_duration)

    elif data.startswith("dur_"):
        duration_map = {
            "dur_1d": "1 Day",
            "dur_7d": "7 Days",
            "dur_30d": "30 Days",
            "dur_life": "Lifetime"
        }
        chosen_dur = duration_map.get(data, "Lifetime")
        user_state[chat_id] = {"duration": chosen_dur}
        prompt_device_scope(chat_id, msg_id, chosen_dur)

    elif data == "scope_custom":
        msg = bot.send_message(chat_id, "✏️ *Please reply with your custom device limit* (e.g., `3 Devices`, `10 Devices`):", parse_mode="Markdown")
        bot.register_next_step_handler(msg, process_custom_device)

    elif data.startswith("scope_"):
        scope_map = {
            "scope_single": "1 Device (Bound)",
            "scope_global": "Global (All Devices)"
        }
        chosen_scope = scope_map.get(data, "Global (All Devices)")
        state = user_state.get(chat_id, {"duration": "Lifetime"})
        duration = state.get("duration", "Lifetime")
        finalize_key_generation(chat_id, msg_id, duration, chosen_scope)

    elif data == "manage_keys":
        owner_keys = {k: v for k, v in keys_db.items() if v.get("owner") == str(chat_id) and v.get("status") == "Active"}
        if not owner_keys:
            text = "ℹ️ *Key Status & Device UUID Binding*\n\nYou currently have no active generated keys."
            markup = InlineKeyboardMarkup()
            markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=text, parse_mode="Markdown", reply_markup=markup)
            return

        text = f"ℹ️ *Active Keys & Device UUID Status ({len(owner_keys)})*\n\n"
        markup = InlineKeyboardMarkup(row_width=1)
        for key_str, info in list(owner_keys.items())[:10]:
            bound_devices = info.get("bound_devices", [])
            device_count = len(bound_devices)
            scope = info.get("scope", "1 Device")
            dur = info.get("duration", "Lifetime")

            text += (
                f"🔑 *Key:* `{key_str}`\n"
                f"⏱️ *Duration:* {dur}\n"
                f"📱 *Scope:* {scope}\n"
                f"🔗 *Bound Devices:* {device_count} UUID(s) bound\n"
            )
            if bound_devices:
                for idx, uuid in enumerate(bound_devices, 1):
                    text += f"   • Device #{idx}: `{uuid}`\n"
            text += "\n"

            btn_label = f"❌ Revoke: {key_str}"
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

def process_custom_duration(message):
    chat_id = message.chat.id
    custom_dur = message.text.strip()
    if not custom_dur:
        custom_dur = "Custom Duration"
    user_state[chat_id] = {"duration": custom_dur}

    markup = InlineKeyboardMarkup(row_width=1)
    btn_single = InlineKeyboardButton("📱 1 Device (Bound)", callback_data="scope_single")
    btn_global = InlineKeyboardButton("🌐 Global Key (All Devices)", callback_data="scope_global")
    btn_custom = InlineKeyboardButton("✏️ Manual Custom Devices", callback_data="scope_custom")
    btn_back = InlineKeyboardButton("🔙 Back", callback_data="start_gen")
    markup.add(btn_single, btn_global, btn_custom, btn_back)

    bot.send_message(
        chat_id,
        f"📱 *Step 2: Select Device Scope*\nSelected Duration: `{custom_dur}`",
        parse_mode="Markdown",
        reply_markup=markup
    )

def process_custom_device(message):
    chat_id = message.chat.id
    custom_scope = message.text.strip()
    if not custom_scope:
        custom_scope = "Custom Devices"
    state = user_state.get(chat_id, {"duration": "Lifetime"})
    duration = state.get("duration", "Lifetime")

    key_str = generate_key_string()
    keys_db[key_str] = {
        "duration": duration,
        "scope": custom_scope,
        "status": "Active",
        "owner": str(chat_id),
        "bound_devices": []
    }
    save_keys(keys_db)

    result_text = (
        "✅ *V4RTEXX LICENSE KEY GENERATED*\n\n"
        f"`{key_str}`\n\n"
        f"⏱️ *Duration:* {duration}\n"
        f"🌐 *Scope:* {custom_scope}\n"
        f"🔗 *Bound Devices:* 0 UUID(s) bound\n\n"
        "📋 _Tap key above to copy, then paste it in V4RTEXX MANAGER app._"
    )
    markup = InlineKeyboardMarkup(row_width=1)
    btn_gen_another = InlineKeyboardButton("🔄 Generate Another Key", callback_data="start_gen")
    btn_menu = InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu")
    markup.add(btn_gen_another, btn_menu)

    bot.send_message(chat_id, result_text, parse_mode="Markdown", reply_markup=markup)

def prompt_device_scope(chat_id, msg_id, duration):
    markup = InlineKeyboardMarkup(row_width=1)
    btn_single = InlineKeyboardButton("📱 1 Device (Bound)", callback_data="scope_single")
    btn_global = InlineKeyboardButton("🌐 Global Key (All Devices)", callback_data="scope_global")
    btn_custom = InlineKeyboardButton("✏️ Manual Custom Devices", callback_data="scope_custom")
    btn_back = InlineKeyboardButton("🔙 Back", callback_data="start_gen")
    markup.add(btn_single, btn_global, btn_custom, btn_back)
    bot.edit_message_text(
        chat_id=chat_id,
        message_id=msg_id,
        text=f"📱 *Step 2: Select Device Scope*\nSelected Duration: `{duration}`",
        parse_mode="Markdown",
        reply_markup=markup
    )

def finalize_key_generation(chat_id, msg_id, duration, scope):
    key_str = generate_key_string()
    keys_db[key_str] = {
        "duration": duration,
        "scope": scope,
        "status": "Active",
        "owner": str(chat_id),
        "bound_devices": []
    }
    save_keys(keys_db)

    result_text = (
        "✅ *V4RTEXX LICENSE KEY GENERATED*\n\n"
        f"`{key_str}`\n\n"
        f"⏱️ *Duration:* {duration}\n"
        f"🌐 *Scope:* {scope}\n"
        f"🔗 *Bound Devices:* 0 UUID(s) bound\n\n"
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

if __name__ == "__main__":
    print("V4RTEXX Telegram Bot is running...")
    bot.infinity_polling()
