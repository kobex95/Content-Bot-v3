<h1 align="center">
  Save Restricted Content Bot v3
</h1>

Save Restricted Content Bot 是由 devgagan 和 TEAM SPY 开发的稳定 Telegram 机器人。它允许用户从 Telegram 频道和群组中获取受限消息，提供自定义缩略图支持以及上传最大 4GB 文件的功能。此外，该机器人还支持从 YouTube、Instagram、Facebook 等 100 多个网站下载视频。

[Telegram](https://t.me/save_restricted_content_bots) | [查看最近更新](https://github.com/devgaganin/Save-Restricted-Content-Bot-V2/tree/v3#updates)

### 为项目点赞以激励我们更新新功能
请帮忙点赞并 Fork，谢谢！ 

## 📚 关于此分支
- 此分支基于 `Pyrogram V2`，提供更强的稳定性和强制登录功能。对于公开频道，用户不需要登录机器人，但对于公开群组和私有频道，用户必须登录。
- 详细功能请向下滚动查看功能部分

---

## 🔧 功能特性
- 从公开和私有频道/群组提取内容
- 添加了自定义机器人功能，使用 `/setbot`
- 数据保存采用 128 位加密，在 Telegram 上使用 @v3saverbot 生成 `MASTER_KEY`、`IV_KEY`
- 重命名并转发内容到其他频道或用户
- 从其他机器人提取受限内容，链接格式如 `https://botusername(不带 @)/message_id(从 Plus Messenger 获取)`
- `/login` 方法以及基于 `session` 的登录
- 自定义字幕和缩略图
- 自动删除默认视频缩略图
- 删除或替换文件名和字幕中的单词
- 如果启用则自动固定消息
- 从 YouTube/Instagram/Twitter/Facebook 等支持 yt-dlp 的网站下载最佳格式的视频
- 通过电话号码登录
- **支持 4GB 文件上传**：机器人可以处理最大 4GB 的大文件上传
- 如果不是 premium 字符串则使用文件分割
- **增强的计时器**：为免费和付费用户提供不同的计时器，以限制使用并改善服务
- **改进的循环**：优化处理多个文件或链接的循环，减少延迟并提升性能
- **高级访问**：高级用户享受更快的处理速度和优先队列管理
- ~~广告设置短链接广告令牌系统~~
- ~~通过 `SpyLib` 使用 Telethon 模块和 `mautrix bridge repo` 快速上传~~
- 直接上传到任何启用了主题的群组的 `topic`
- 实时下载和上传进度，支持聊天、文本、音频、视频、视频笔记、贴纸等所有内容

  
## ⚡ 命令

- **`start`**: 🚀 启动机器人
- **`batch`**: 🫠 批量提取
- **`login`**: 🔑 登录机器人
- **`single`**: 处理单个链接
- **`setbot`**: 添加您的自定义机器人
- **`logout`**: 🚪 登出机器人
- **`adl`**: 👻 从 30+ 个网站下载音频
- **`dl`**: 💀 从 30+ 个网站下载视频
- **`transfer`**: 💘 赠送高级会员给他人
- **`status`**: ⌛ 获取您的计划详情
- **`add`**: ➕ 添加用户为高级会员
- **`rem`**: ➖ 移除用户的高级会员
- **`rembot`**: 移除您的自定义机器人
- **`session`**: 🧵 生成 Pyrogramv2 会话
- **`settings`**: ⚙️ 个性化设置
- **`stats`**: 📊 获取机器人统计信息
- **`plan`**: 🗓️ 查看我们的高级计划
- **`terms`**: 🥺 服务条款和条件
- **`help`**: ❓ 如果您是新用户，获取帮助
- **`cancel`**: 🚫 取消批量处理


## ⚙️ 必需变量

<details>
<summary><b>点击查看必需变量</b></summary>

要运行机器人，您需要配置几个敏感变量。以下是安全设置的方法：

- **`API_ID`**: 您从 [telegram.org](https://my.telegram.org/auth) 获取的 API ID
- **`API_HASH`**: 您从 [telegram.org](https://my.telegram.org/auth) 获取的 API Hash
- **`BOT_TOKEN`**: 从 [@BotFather](https://t.me/botfather) 获取您的机器人令牌
- **`OWNER_ID`**: 使用 [@missrose_bot](https://t.me/missrose_bot) 发送 `/info` 获取您的用户 ID
- **`CHANNEL_ID`**: 强制订阅频道的 ID
- **`LOG_GROUP`**: 机器人记录消息的群组或频道。转发消息给 [@userinfobot](https://t.me/userinfobot) 获取您的频道/群组 ID
- **`MONGO_DB`**: 用于存储会话数据的 MongoDB URL（推荐用于安全）

### 其他配置选项：
- **`STRING`**: （可选）在此处添加您的**高级账户会话字符串**以允许 4GB 文件上传。这是**可选的**，如果不使用可以留空
- **`FREEMIUM_LIMIT`**: 默认为 `0`。设置为您想要的任何值以允许免费用户提取内容。如果设置为 `0`，免费用户将无法访问任何提取功能
- **`PREMIUM_LIMIT`**: 默认为 `500`。这是高级用户的批量限制。您可以自定义此值以允许高级用户在一次批量中处理更多链接/文件
- **`YT_COOKIES`**: 用于下载 YouTube 视频的 YouTube cookies
- **`INSTA_COOKIES`**: 如果您想启用 Instagram 下载，请填写 cookies

**如何获取 cookies？**：如果在 Android 上使用 Mozilla Firefox 或在桌面上使用 Chrome，下载"Get cookies.txt LOCALLY"或任何 Netscape Cookies (HTTP Cookies) 提取器扩展并使用它

### 变现（可选）：
- **`WEBSITE_URL`**: （可选）这是您的变现短链接服务的域名。提供缩短器的域名，例如：`upshrink.com`。**不要**包含 `www` 或 `https://`。默认链接缩短器已设置
- **`AD_API`**: （可选）从您的链接缩短服务（例如 **Upshrink**、**AdFly** 等）获取的 API 密钥，用于链接变现。输入您的缩短器提供的 API

> **重要提示**：始终保护您的凭据安全！永远不要在代码库中硬编码它们。使用环境变量或 `.env` 文件

</details>

---

## 🚀 部署指南

<details>
<summary><b>部署到 VPS</b></summary>

1. Fork 此仓库
2. 使用您的值更新 `config.py`
3. 运行以下命令：
   ```bash
   sudo apt update
   sudo apt install ffmpeg git python3-pip
   git clone your_repo_link
   cd your_repo_name
   pip3 install -r requirements.txt
   python3 main.py
   ```

- 要在后台运行机器人：
  ```bash
  screen -S gagan
  python3 main.py
  ```
  - 分离：`Ctrl + A`，然后 `Ctrl + D`
  - 停止：`screen -r gagan` 和 `screen -S gagan -X quit`

</details>

<details>
<summary><b>部署到 Heroku</b></summary>

1. Fork 并为仓库点赞
2. 点击 [![部署](https://www.herokucdn.com/deploy/button.svg)](https://www.heroku.com/deploy)
3. 输入必需变量并点击部署 ✅

</details>

<details>
<summary><b>部署到 Render</b></summary>

1. Fork 并为仓库点赞
2. 编辑 `config.py` 或在 Render 上设置环境变量
3. 访问 [render.com](https://render.com)，注册/登录
4. 创建新的 Web 服务，选择免费计划
5. 连接您的 GitHub 仓库并部署 ✅

</details>

<details>
<summary><b>部署到 Koyeb</b></summary>

1. Fork 并为仓库点赞
2. 编辑 `config.py` 或在 Koyeb 上设置环境变量
3. 创建新服务，选择 `Dockerfile` 作为构建类型
4. 连接您的 GitHub 仓库并部署 ✅

</details>

---
### ⚠️ 必须做：保护您的敏感变量

**不要在 GitHub 上公开敏感变量（例如 `API_ID`、`API_HASH`、`BOT_TOKEN`）。使用环境变量来保护它们。**

### 安全配置变量：

- **在 VPS 或本地机器上：**
  - 使用文本编辑器编辑 `config.py`：
    ```bash
    nano config.py
    ```
  - 或者，导出为环境变量：
    ```bash
    export API_ID=your_api_id
    export API_HASH=your_api_hash
    export BOT_TOKEN=your_bot_token
    ```

- **对于云平台（Heroku、Railway 等）：**
  - 直接在平台的仪表板中设置环境变量

- **使用 `.env` 文件：**
  - 创建 `.env` 文件并添加您的凭据：
    ```
    API_ID=your_api_id
    API_HASH=your_api_hash
    BOT_TOKEN=your_bot_token
    ```
  - 确保将 `.env` 添加到 `.gitignore` 以防止它被推送到 GitHub

**为什么这很重要？**
如果推送到公共仓库，您的凭据可能会被窃取。始终通过使用环境变量或本地配置文件来保护它们。

---

## 🛠️ 使用条款

访问 [使用条款](https://github.com/devgaganin/Save-Restricted-Content-Bot-Repo/blob/master/TERMS_OF_USE.md) 页面以查看并接受准则。

## 重要提示

**注意**：更改条款和命令并不能神奇地让您成为开发者。真正的开发涉及理解代码、编写新功能和调试问题，而不仅仅是重命名事物。如果事情真的那么简单就好了！


<h3 align="center">
  由 <a href="https://t.me/team_spy_pro"> Gagan </a> 用 ❤️ 开发
</h3>

