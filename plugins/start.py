# Copyright (c) 2025 devgagan : https://github.com/devgaganin.  
# Licensed under the GNU General Public License v3.0.  
# See LICENSE file in the repository root for full license text.

from shared_client import app
from pyrogram import filters
from pyrogram.errors import UserNotParticipant
from pyrogram.types import BotCommand, InlineKeyboardButton, InlineKeyboardMarkup
from config import LOG_GROUP, OWNER_ID, FORCE_SUB

async def subscribe(app, message):
    if FORCE_SUB:
        try:
          user = await app.get_chat_member(FORCE_SUB, message.from_user.id)
          if str(user.status) == "ChatMemberStatus.BANNED":
              await message.reply_text("您已被封禁。请联系 -- Team SPY")
              return 1
        except UserNotParticipant:
            link = await app.export_chat_invite_link(FORCE_SUB)
            caption = f"请加入我们的频道以使用机器人"
            await message.reply_photo(photo="https://graph.org/file/d44f024a08ded19452152.jpg",caption=caption, reply_markup=InlineKeyboardMarkup([[InlineKeyboardButton("立即加入...", url=f"{link}")]]))
            return 1
        except Exception as ggn:
            await message.reply_text(f"出现错误。请联系管理员... 错误信息: {ggn}")
            return 1 
     
@app.on_message(filters.command("set"))
async def set(_, message):
    if message.from_user.id not in OWNER_ID:
        await message.reply("您没有权限使用此命令。")
        return

    await app.set_bot_commands([
        BotCommand("start", "🚀 启动机器人"),
        BotCommand("batch", "🫠 批量提取"),
        BotCommand("login", "🔑 登录机器人"),
        BotCommand("setbot", "🧸 添加您的机器人处理文件"),
        BotCommand("logout", "🚪 退出机器人"),
        BotCommand("adl", "👻 从30+网站下载音频"),
        BotCommand("dl", "💀 从30+网站下载视频"),
        BotCommand("status", "⟳ 刷新支付状态"),
        BotCommand("transfer", "💘 转赠会员给他人"),
        BotCommand("add", "➕ 添加用户为会员"),
        BotCommand("rem", "➖ 移除会员"),
        BotCommand("rembot", "🤨 移除自定义机器人"),
        BotCommand("settings", "⚙️ 个性化设置"),
        BotCommand("plan", "🗓️ 查看会员计划"),
        BotCommand("terms", "🥺 条款和条件"),
        BotCommand("help", "❓ 帮助信息"),
        BotCommand("cancel", "🚫 取消登录/批量/设置流程"),
        BotCommand("stop", "🚫 取消批量处理")
    ])

    await message.reply("✅ 命令配置成功!")
 
 
 
 
help_pages = [
    (
        "📝 **机器人命令说明 (1/2)**:\n\n"
        "1. **/add userID**\n"
        "> 添加用户为会员 (仅管理员)\n\n"
        "2. **/rem userID**\n"
        "> 移除会员 (仅管理员)\n\n"
        "3. **/transfer userID**\n"
        "> 转赠会员给他人 (仅会员可用)\n\n"
        "4. **/get**\n"
        "> 获取所有用户ID (仅管理员)\n\n"
        "5. **/lock**\n"
        "> 锁定频道禁止提取 (仅管理员)\n\n"
        "6. **/dl link**\n"
        "> 下载视频 (V3版本暂不可用)\n\n"
        "7. **/adl link**\n"
        "> 下载音频 (V3版本暂不可用)\n\n"
        "8. **/login**\n"
        "> 登录以访问私有频道\n\n"
        "9. **/batch**\n"
        "> 批量提取帖子 (登录后可用)\n\n"
    ),
    (
        "📝 **机器人命令说明 (2/2)**:\n\n"
        "10. **/logout**\n"
        "> 退出登录\n\n"
        "11. **/stats**\n"
        "> 查看机器人统计\n\n"
        "12. **/plan**\n"
        "> 查看会员计划\n\n"
        "13. **/speedtest**\n"
        "> 测试服务器速度 (V3版本不可用)\n\n"
        "14. **/terms**\n"
        "> 条款和条件\n\n"
        "15. **/cancel**\n"
        "> 取消进行中的批量处理\n\n"
        "16. **/myplan**\n"
        "> 查看您的会员详情\n\n"
        "17. **/session**\n"
        "> 生成 Pyrogram V2 会话\n\n"
        "18. **/settings**\n"
        "> 1. SETCHATID : 直接上传到频道/群组/私聊,使用 -100[chatID]\n"
        "> 2. SETRENAME : 添加自定义重命名标签或频道用户名\n"
        "> 3. CAPTION : 添加自定义说明文字\n"
        "> 4. REPLACEWORDS : 替换文字,可与删除功能配合使用\n"
        "> 5. RESET : 恢复默认设置\n\n"
        "> 您可以在设置中配置自定义缩略图、PDF水印、视频水印、会话登录等\n\n"
        "**__Powered by Team SPY__**"
    )
]
 
 
async def send_or_edit_help_page(_, message, page_number):
    if page_number < 0 or page_number >= len(help_pages):
        return
 

    prev_button = InlineKeyboardButton("◀️ 上一页", callback_data=f"help_prev_{page_number}")
    next_button = InlineKeyboardButton("下一页 ▶️", callback_data=f"help_next_{page_number}")
 
     
    buttons = []
    if page_number > 0:
        buttons.append(prev_button)
    if page_number < len(help_pages) - 1:
        buttons.append(next_button)
 
     
    keyboard = InlineKeyboardMarkup([buttons])
 
     
    await message.delete()
 
     
    await message.reply(
        help_pages[page_number],
        reply_markup=keyboard
    )
 
 
@app.on_message(filters.command("help"))
async def help(client, message):
    join = await subscribe(client, message)
    if join == 1:
        return
     
    await send_or_edit_help_page(client, message, 0)
 
 
@app.on_callback_query(filters.regex(r"help_(prev|next)_(\d+)"))
async def on_help_navigation(client, callback_query):
    action, page_number = callback_query.data.split("_")[1], int(callback_query.data.split("_")[2])
 
    if action == "prev":
        page_number -= 1
    elif action == "next":
        page_number += 1

    await send_or_edit_help_page(client, callback_query.message, page_number)
     
    await callback_query.answer()

 
@app.on_message(filters.command("terms") & filters.private)
async def terms(client, message):
    terms_text = (
        "> 📜 **条款和条件** 📜\n\n"
        "✨ 我们不对用户行为负责,不提倡版权内容。任何用户从事此类活动,均由其自行承担责任。\n"
        "✨ 购买后,我们不保证运行时间、停机时间或计划的有效性。__授权和封禁用户由我们决定,我们保留随时封禁或授权用户的权利.__\n"
        "✨ 付款给我们**__不保证__** /batch 命令的授权。所有关于授权的决定都由我们根据情况和心情决定。\n"
    )

    buttons = InlineKeyboardMarkup(
        [
            [InlineKeyboardButton("📋 查看计划", callback_data="see_plan")],
            [InlineKeyboardButton("💬 联系我们", url="https://t.me/kingofpatal")],
        ]
    )
    await message.reply_text(terms_text, reply_markup=buttons)
 
 
@app.on_message(filters.command("plan") & filters.private)
async def plan(client, message):
    plan_text = (
        "> 💰 **会员价格**:\n\n 起价 $2 或 200 INR,接受 **__亚马逊礼品卡__** 支付(适用条款和条件)。\n"
        "📥 **下载限制**: 用户可以在单个批量命令中下载多达 100,000 个文件。\n"
        "🛑 **批量模式**: 您将获得两种模式 /bulk 和 /batch。\n"
        "   - 建议用户等待进程自动取消,然后再进行任何下载或上传。\n\n"
        "📜 **条款和条件**: 更多详情和完整条款,请发送 /terms。\n"
    )

    buttons = InlineKeyboardMarkup(
        [
            [InlineKeyboardButton("📜 查看条款", callback_data="see_terms")],
            [InlineKeyboardButton("💬 联系我们", url="https://t.me/kingofpatal")],
        ]
    )
    await message.reply_text(plan_text, reply_markup=buttons)
 
 
@app.on_callback_query(filters.regex("see_plan"))
async def see_plan(client, callback_query):
    plan_text = (
        "> 💰**会员价格**\n\n 起价 $2 或 200 INR,接受 **__亚马逊礼品卡__** 支付(适用条款和条件)。\n"
        "📥 **下载限制**: 用户可以在单个批量命令中下载多达 100,000 个文件。\n"
        "🛑 **批量模式**: 您将获得两种模式 /bulk 和 /batch。\n"
        "   - 建议用户等待进程自动取消,然后再进行任何下载或上传。\n\n"
        "📜 **条款和条件**: 更多详情和完整条款,请发送 /terms 或点击下方查看条款👇\n"
    )

    buttons = InlineKeyboardMarkup(
        [
            [InlineKeyboardButton("📜 查看条款", callback_data="see_terms")],
            [InlineKeyboardButton("💬 联系我们", url="https://t.me/kingofpatal")],
        ]
    )
    await callback_query.message.edit_text(plan_text, reply_markup=buttons)
 
 
@app.on_callback_query(filters.regex("see_terms"))
async def see_terms(client, callback_query):
    terms_text = (
        "> 📜 **条款和条件** 📜\n\n"
        "✨ 我们不对用户行为负责,不提倡版权内容。任何用户从事此类活动,均由其自行承担责任。\n"
        "✨ 购买后,我们不保证运行时间、停机时间或计划的有效性。__授权和封禁用户由我们决定,我们保留随时封禁或授权用户的权利.__\n"
        "✨ 付款给我们**__不保证__** /batch 命令的授权。所有关于授权的决定都由我们根据情况和心情决定。\n"
    )

    buttons = InlineKeyboardMarkup(
        [
            [InlineKeyboardButton("📋 查看计划", callback_data="see_plan")],
            [InlineKeyboardButton("💬 联系我们", url="https://t.me/kingofpatal")],
        ]
    )
    await callback_query.message.edit_text(terms_text, reply_markup=buttons)
 
 
