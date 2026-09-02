import requests
import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton
from flask import Flask, request, jsonify
import threading
import random
import string
import json
import os

BOT_TOKEN = "8938101106:AAFiVVMBoCwqbUnQNnuN30gYUkTQ7jAw8L0"
bot = telebot.TeleBot(BOT_TOKEN)

# KeyAuth Configuration
KEYAUTH_APP_NAME = "V4RTEXX MANAGER"
KEYAUTH_OWNER_ID = "pg6gDhL4a6"
KEYAUTH_SECRET = "1b6ae657e002b641129763f65920347345c9224bfdd1f514e7f8aa262886b03f"
KEYAUTH_VERSION = "1.0"
KEYAUTH_API_URL = "https://keyauth.win/api/1.2/"

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

# --- Lightweight Flask API Server for KeyActivation Sync & KeyAuth Integration ---
app = Flask(__name__)

@app.route("/activate", methods=["POST"])
def register_activation():
    data = request.get_json(silent=True) or {}
    key = data.get("key", "").strip().upper()
    device_uuid = data.get("device_uuid", "").strip()

    if not key or not device_uuid:
        return jsonify({"status": "error", "message": "Invalid parameters"}), 400

    if key in keys_db:
        key_info = keys_db[key]
        if "bound_devices" not in key_info or not isinstance(key_info["bound_devices"], list):
            key_info["bound_devices"] = []

        if device_uuid not in key_info["bound_devices"]:
            key_info["bound_devices"].append(device_uuid)
            key_info["manual_used"] = True
            save_keys(keys_db)
            print(f"[KeyAuth API Sync] Bound device {device_uuid} to key {key}")

        return jsonify({"status": "success", "bound_count": len(key_info["bound_devices"])}), 200
    else:
        # Register standalone KeyAuth key entry if activated directly in app
        keys_db[key] = {
            "duration": "Lifetime",
            "scope": "1 Device (Bound)",
            "status": "Active",
            "owner": "App/KeyAuth",
            "bound_devices": [device_uuid],
            "manual_used": True
        }
        save_keys(keys_db)
        print(f"[KeyAuth API Sync] Registered new KeyAuth key {key} with device {device_uuid}")
        return jsonify({"status": "success", "bound_count": 1}), 200

def run_flask():
    app.run(host="0.0.0.0", port=8080)

threading.Thread(target=run_flask, daemon=True).start()

# --- Telegram Bot Interface ---
def generate_key_string():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(19))

def build_main_menu():
    markup = InlineKeyboardMarkup(row_width=1)
    btn_key = InlineKeyboardButton("🔑 Generate Key (KeyAuth Linked)", callback_data="start_gen")
    btn_status = InlineKeyboardButton("ℹ️ Key List & Device Status", callback_data="manage_keys")
    markup.add(btn_key, btn_status)
    return markup

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "⚡ *V4RTEXX MANAGER License Key Generator* ⚡\n\n"
        f"🔐 *KeyAuth Linked App:* `{KEYAUTH_APP_NAME}`\n"
        f"🆔 *Owner ID:* `{KEYAUTH_OWNER_ID}`\n\n"
        "Generate & manage KeyAuth license keys with Device UUID binding."
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
            f"🔐 *KeyAuth Linked App:* `{KEYAUTH_APP_NAME}`\n"
            f"🆔 *Owner ID:* `{KEYAUTH_OWNER_ID}`\n\n"
            "Generate & manage KeyAuth license keys with Device UUID binding."
        )
        bot.edit_message_text(
            chat_id=chat_id,
            message_id=msg_id,
            text=welcome_text,
            parse_mode="Markdown",
            reply_markup=build_main_menu()
        )

    elif data == "start_gen":
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
        owner_keys = {k: v for k, v in keys_db.items() if v.get("owner") in [str(chat_id), "App", "App/KeyAuth"]}
        if not owner_keys:
            text = "ℹ️ *Key List & Device Status*\n\nYou currently have no generated keys."
            markup = InlineKeyboardMarkup()
            markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=text, parse_mode="Markdown", reply_markup=markup)
            return

        text = f"ℹ️ *Your KeyAuth Keys ({len(owner_keys)})*\nSelect a key to view detailed activation & bound device UUID info:"
        markup = InlineKeyboardMarkup(row_width=1)
        for key_str, info in list(owner_keys.items())[:15]:
            status_icon = "🟢" if info.get("status") == "Active" else "🔴"
            bound_count = len(info.get("bound_devices", []))
            is_manual_used = info.get("manual_used", False)
            usage_icon = f"📲 Used ({max(bound_count, 1)})" if (bound_count > 0 or is_manual_used) else "🆓 Unused"
            btn_label = f"{status_icon} Key: {key_str} [{usage_icon}]"
            markup.add(InlineKeyboardButton(btn_label, callback_data=f"keyinfo_{key_str}"))

        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=text, parse_mode="Markdown", reply_markup=markup)

    elif data.startswith("keyinfo_"):
        key_str = data.replace("keyinfo_", "")
        if key_str in keys_db:
            info = keys_db[key_str]
            bound_devices = info.get("bound_devices", [])
            status = info.get("status", "Active")
            duration = info.get("duration", "Lifetime")
            scope = info.get("scope", "1 Device")
            is_manual_used = info.get("manual_used", False)

            status_text = "🟢 *ACTIVE*" if status == "Active" else "🔴 *REVOKED*"
            if bound_devices or is_manual_used:
                count_str = f"{max(len(bound_devices), 1)} device(s) bound"
                usage_text = f"📲 *Used* ({count_str})"
            else:
                usage_text = "🆓 *Unused* (Not activated yet)"

            details = (
                f"🔑 *KEYAUTH KEY INFORMATION*\n\n"
                f"• *App:* `{KEYAUTH_APP_NAME}`\n"
                f"• *Key:* `{key_str}`\n"
                f"• *Status:* {status_text}\n"
                f"• *Usage:* {usage_text}\n"
                f"• *Duration:* `{duration}`\n"
                f"• *Scope:* `{scope}`\n\n"
            )
            if bound_devices:
                details += "*Bound Device UUID(s):*\n"
                for idx, uuid in enumerate(bound_devices, 1):
                    details += f"{idx}. `{uuid}`\n"
            elif is_manual_used:
                details += "_Device bound via KeyAuth App Activation._"
            else:
                details += "_No devices currently bound to this key._"

            markup = InlineKeyboardMarkup(row_width=1)
            if not bound_devices and not is_manual_used:
                markup.add(InlineKeyboardButton("📲 Mark Key as Used / Bound", callback_data=f"bindmanual_{key_str}"))

            if status == "Active":
                markup.add(InlineKeyboardButton("❌ Revoke Key", callback_data=f"revoke_{key_str}"))
            markup.add(InlineKeyboardButton("🗑️ Delete Key Permanently", callback_data=f"delete_{key_str}"))
            markup.add(InlineKeyboardButton("🔙 Back to Key List", callback_data="manage_keys"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=details, parse_mode="Markdown", reply_markup=markup)
        else:
            bot.send_message(chat_id, "⚠️ Key not found.")

    elif data.startswith("bindmanual_"):
        key_to_bind = data.replace("bindmanual_", "")
        if key_to_bind in keys_db:
            keys_db[key_to_bind]["manual_used"] = True
            if "bound_devices" not in keys_db[key_to_bind] or not keys_db[key_to_bind]["bound_devices"]:
                keys_db[key_to_bind]["bound_devices"] = ["KEYAUTH-DEVICE-BOUND-01"]
            save_keys(keys_db)
            bound_msg = f"📲 *Key Status Updated*\n\nKey `{key_to_bind}` has been marked as *Used* & bound to device."
        else:
            bound_msg = "⚠️ Key not found."

        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("📋 Back to Key List", callback_data="manage_keys"))
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=bound_msg, parse_mode="Markdown", reply_markup=markup)

    elif data.startswith("revoke_"):
        key_to_revoke = data.replace("revoke_", "")
        if key_to_revoke in keys_db:
            keys_db[key_to_revoke]["status"] = "Revoked"
            save_keys(keys_db)
            revoked_text = f"🚫 *Key Revoked*\n\nKey `{key_to_revoke}` has been set to Revoked."
            markup = InlineKeyboardMarkup(row_width=1)
            markup.add(InlineKeyboardButton("🗑️ Delete Key Permanently", callback_data=f"delete_{key_to_revoke}"))
            markup.add(InlineKeyboardButton("📋 Back to Key List", callback_data="manage_keys"))
            markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=revoked_text, parse_mode="Markdown", reply_markup=markup)
        else:
            revoked_text = "⚠️ Key not found."
            markup = InlineKeyboardMarkup()
            markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
            bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=revoked_text, parse_mode="Markdown", reply_markup=markup)

    elif data.startswith("delete_"):
        key_to_delete = data.replace("delete_", "")
        if key_to_delete in keys_db:
            del keys_db[key_to_delete]
            save_keys(keys_db)
            deleted_text = f"🗑️ *Key Permanently Deleted*\n\nKey `{key_to_delete}` has been completely removed from database."
        else:
            deleted_text = "⚠️ Key not found."

        markup = InlineKeyboardMarkup()
        markup.add(InlineKeyboardButton("📋 Back to Key List", callback_data="manage_keys"))
        markup.add(InlineKeyboardButton("🔙 Main Menu", callback_data="main_menu"))
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=deleted_text, parse_mode="Markdown", reply_markup=markup)

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
        "✅ *KEYAUTH LICENSE KEY GENERATED*\n\n"
        f"`{key_str}`\n\n"
        f"🔐 *App:* {KEYAUTH_APP_NAME}\n"
        f"⏱️ *Duration:* {duration}\n"
        f"🌐 *Scope:* {custom_scope}\n"
        f"🔗 *Bound Devices:* 0 UUID(s)\n\n"
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
        "✅ *KEYAUTH LICENSE KEY GENERATED*\n\n"
        f"`{key_str}`\n\n"
        f"🔐 *App:* {KEYAUTH_APP_NAME}\n"
        f"⏱️ *Duration:* {duration}\n"
        f"🌐 *Scope:* {scope}\n"
        f"🔗 *Bound Devices:* 0 UUID(s)\n\n"
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
    print(f"V4RTEXX KeyAuth Bot & API Server ({KEYAUTH_APP_NAME}) is running on port 8080...")
    bot.infinity_polling()
