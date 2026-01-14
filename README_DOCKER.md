# Content-Bot Docker 镜像

Content-Bot Docker 镜像，支持多架构部署，一键运行 Telegram 内容提取机器人。

## 🚀 快速启动

### 使用 Docker

```bash
# 拉取镜像
docker pull kobex95/content-bot:latest

# 运行容器
docker run -d \\
  --name content-bot \\
  -p 5000:5000 \\
  --env-file .env \\
  kobex95/content-bot:latest
```

### 使用 Docker Compose

创建 docker-compose.yml 文件：

```yaml
version: '3.8'

services:
  content-bot:
    image: kobex95/content-bot:latest
    container_name: content-bot
    restart: unless-stopped
    ports:
      - "5000:5000"
    env_file:
      - .env
    volumes:
      - ./sessions:/app/sessions
      - ./logs:/app/logs
```

启动服务：

```bash
docker-compose up -d
```

## 📋 支持的架构

| 架构 | 平台 | 说明 |
|------|------|------|
| x86_64 | linux/amd64 | 标准服务器 |
| ARM64 | linux/arm64 | 现代 ARM 设备 |
| ARMv7 | linux/arm/v7 | 树莓派等设备 |

## 🔧 环境配置

创建 .env 文件并配置以下参数：

```bash
# Telegram API 配置
API_ID=your_api_id
API_HASH=your_api_hash
BOT_TOKEN=your_bot_token

# 数据库配置
MONGO_DB=mongodb+srv://username:password@cluster.mongodb.net/telegram_downloader
DB_NAME=telegram_downloader

# 管理员配置
OWNER_ID=123456789
LOG_GROUP=-1001234567890
FORCE_SUB=-1001234567890

# 安全配置
MASTER_KEY=your_random_key
IV_KEY=your_random_iv_key
```

## 📖 详细文档

- Docker 部署指南: ./.mcai/docs/Docker部署指南.md
- Docker Hub 推送指南: ./.mcai/docs/DockerHub推送指南.md
- 项目文档: ./.mcai/docs/0.INDEX.md

## 🌐 镜像信息

- Docker Hub: kobex95/content-bot
- 大小: 约 500MB (基于 python:3.10-slim)
- 标签策略: 
  - latest: 最新稳定版本
  - v1.0.0: 特定版本标签
  - master: 主分支构建

## 🔍 健康检查

```bash
# 检查容器状态
docker ps | grep content-bot

# 查看健康状态
docker inspect --format={{json .State.Health}} content-bot

# 查看日志
docker logs -f content-bot
```

## 🆘 获取帮助

- 项目主页: https://github.com/kobex95/Content-Bot-v3
- 问题反馈: https://github.com/kobex95/Content-Bot-v3/issues
- 技术支持: https://t.me/team_spy_pro
