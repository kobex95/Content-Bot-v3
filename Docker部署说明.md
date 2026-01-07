# Content-Bot-v3 Docker 部署完整指南

## 目录
- [环境准备](#环境准备)
- [Dockerfile 配置](#dockerfile-配置)
- [构建 Docker 镜像](#构建-docker-镜像)
- [推送到 Docker Hub](#推送到-docker-hub)
- [从 Docker Hub 拉取和运行](#从-docker-hub-拉取和运行)
- [本地运行 Docker 容器](#本地运行-docker-容器)
- [常见问题](#常见问题)

---

## 环境准备

### 1. 安装 Docker

#### Windows 系统
```powershell
# 下载并安装 Docker Desktop
# 访问：https://www.docker.com/products/docker-desktop
# 下载后按照安装向导完成安装
```

#### Linux 系统 (Ubuntu/Debian)
```bash
# 更新包索引
sudo apt update

# 安装依赖包
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置稳定版仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
docker --version
```

### 2. 安装 Docker Compose（可选）
```bash
# Linux 系统
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 3. 注册 Docker Hub 账号
- 访问：https://hub.docker.com/signup
- 注册账号并登录
- 记住您的 Docker Hub 用户名

---

## Dockerfile 配置

### 当前 Dockerfile 内容
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 暴露端口（如果有 Web 服务）
# EXPOSE 5000

# 运行应用
CMD ["python3", "main.py"]
```

### Dockerfile 说明
- **基础镜像**：使用 Python 3.11 的轻量级版本
- **工作目录**：设置为 `/app`
- **系统依赖**：安装 ffmpeg（视频处理）和 git
- **Python 依赖**：从 requirements.txt 安装
- **应用文件**：复制所有项目文件到容器
- **启动命令**：运行 main.py

---

## 构建 Docker 镜像

### 方法一：使用 Docker 命令行

#### 1. 确保在项目根目录
```bash
cd /path/to/Content-Bot-v3
```

#### 2. 构建 Docker 镜像
```bash
# 基本构建命令
docker build -t content-bot-v3:latest .

# 带标签构建（推荐）
docker build -t your-dockerhub-username/content-bot-v3:latest .
docker build -t your-dockerhub-username/content-bot-v3:v1.0 .

# 无缓存构建（确保使用最新依赖）
docker build --no-cache -t content-bot-v3:latest .
```

#### 3. 查看构建的镜像
```bash
# 列出所有镜像
docker images

# 查看特定镜像详情
docker inspect content-bot-v3:latest
```

### 方法二：使用 Docker Compose（推荐）

#### 1. 创建 docker-compose.yml 文件
```yaml
version: '3.8'

services:
  content-bot:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: content-bot-v3
    restart: unless-stopped
    environment:
      # 从环境变量读取配置
      - API_ID=${API_ID}
      - API_HASH=${API_HASH}
      - BOT_TOKEN=${BOT_TOKEN}
      - OWNER_ID=${OWNER_ID}
      - CHANNEL_ID=${CHANNEL_ID}
      - LOG_GROUP=${LOG_GROUP}
      - MONGO_DB=${MONGO_DB}
      - STRING=${STRING}
      - FREEMIUM_LIMIT=${FREEMIUM_LIMIT}
      - PREMIUM_LIMIT=${PREMIUM_LIMIT}
      - YT_COOKIES=${YT_COOKIES}
      - INSTA_COOKIES=${INSTA_COOKIES}
      - WEBSITE_URL=${WEBSITE_URL}
      - AD_API=${AD_API}
      - MASTER_KEY=${MASTER_KEY}
      - IV_KEY=${IV_KEY}
    volumes:
      # 挂载会话数据目录
      - ./sessions:/app/sessions
      # 挂载下载目录
      - ./downloads:/app/downloads
    # 网络配置
    # ports:
    #   - "5000:5000"
```

#### 2. 创建 .env 文件（重要！）
```bash
# 复制示例文件
cp .env.example .env

# 编辑 .env 文件，填入您的配置
nano .env
```

.env 文件示例：
```env
API_ID=12345678
API_HASH=your_api_hash_here
BOT_TOKEN=your_bot_token_here
OWNER_ID=123456789
CHANNEL_ID=-1001234567890
LOG_GROUP=-1001234567890
MONGO_DB=mongodb+srv://username:password@cluster.mongodb.net/bot
STRING=
FREEMIUM_LIMIT=0
PREMIUM_LIMIT=500
YT_COOKIES=
INSTA_COOKIES=
WEBSITE_URL=
AD_API=
MASTER_KEY=gK8HzLfT9QpViJcYeB5wRa3DmN7P2xUq
IV_KEY=s7Yx5CpVmE3F
```

#### 3. 使用 Docker Compose 构建
```bash
# 构建镜像
docker-compose build

# 查看构建日志
docker-compose build --progress=plain
```

---

## 推送到 Docker Hub

### 1. 登录 Docker Hub
```bash
# 登录（会提示输入用户名和密码）
docker login

# 或指定用户名登录
docker login -u your-dockerhub-username
```

### 2. 标记镜像
```bash
# 标记镜像为 Docker Hub 格式
docker tag content-bot-v3:latest your-dockerhub-username/content-bot-v3:latest

# 添加版本标签
docker tag content-bot-v3:latest your-dockerhub-username/content-bot-v3:v1.0
```

### 3. 推送镜像
```bash
# 推送最新版本
docker push your-dockerhub-username/content-bot-v3:latest

# 推送特定版本
docker push your-dockerhub-username/content-bot-v3:v1.0

# 推送所有标签
docker push -a your-dockerhub-username/content-bot-v3
```

### 4. 验证推送
```bash
# 在 Docker Hub 网站查看
# https://hub.docker.com/r/your-dockerhub-username/content-bot-v3

# 或使用命令行查看
docker search your-dockerhub-username/content-bot-v3
```

### 5. 设置镜像为公开（可选）
- 登录 Docker Hub 网站
- 找到您的仓库 `content-bot-v3`
- 进入 Settings -> Make Public
- 这样其他人就可以拉取您的镜像

---

## 从 Docker Hub 拉取和运行

### 1. 在服务器上拉取镜像
```bash
# 拉取最新版本
docker pull your-dockerhub-username/content-bot-v3:latest

# 拉取特定版本
docker pull your-dockerhub-username/content-bot-v3:v1.0
```

### 2. 运行容器（命令行方式）
```bash
# 基本运行命令
docker run -d \
  --name content-bot-v3 \
  --restart unless-stopped \
  -e API_ID=your_api_id \
  -e API_HASH=your_api_hash \
  -e BOT_TOKEN=your_bot_token \
  -e OWNER_ID=your_owner_id \
  -e CHANNEL_ID=your_channel_id \
  -e LOG_GROUP=your_log_group \
  -e MONGO_DB=your_mongo_url \
  your-dockerhub-username/content-bot-v3:latest

# 完整运行命令（包含所有环境变量）
docker run -d \
  --name content-bot-v3 \
  --restart unless-stopped \
  -e API_ID=${API_ID} \
  -e API_HASH=${API_HASH} \
  -e BOT_TOKEN=${BOT_TOKEN} \
  -e OWNER_ID=${OWNER_ID} \
  -e CHANNEL_ID=${CHANNEL_ID} \
  -e LOG_GROUP=${LOG_GROUP} \
  -e MONGO_DB=${MONGO_DB} \
  -e STRING=${STRING} \
  -e FREEMIUM_LIMIT=${FREEMIUM_LIMIT} \
  -e PREMIUM_LIMIT=${PREMIUM_LIMIT} \
  -e YT_COOKIES=${YT_COOKIES} \
  -e INSTA_COOKIES=${INSTA_COOKIES} \
  -e WEBSITE_URL=${WEBSITE_URL} \
  -e AD_API=${AD_API} \
  -e MASTER_KEY=${MASTER_KEY} \
  -e IV_KEY=${IV_KEY} \
  -v $(pwd)/sessions:/app/sessions \
  -v $(pwd)/downloads:/app/downloads \
  your-dockerhub-username/content-bot-v3:latest
```

### 3. 运行容器（Docker Compose 方式，推荐）

#### 创建 docker-compose.yml
```yaml
version: '3.8'

services:
  content-bot:
    image: your-dockerhub-username/content-bot-v3:latest
    container_name: content-bot-v3
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./sessions:/app/sessions
      - ./downloads:/app/downloads
```

#### 启动服务
```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看服务状态
docker-compose ps
```

---

## 本地运行 Docker 容器

### 1. 构建并运行
```bash
# 一次性构建并运行
docker-compose up -d --build
```

### 2. 管理容器
```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日志
docker logs -f content-bot-v3

# 查看最近的日志
docker logs --tail 100 content-bot-v3

# 进入容器（调试用）
docker exec -it content-bot-v3 /bin/bash

# 停止容器
docker stop content-bot-v3

# 启动已停止的容器
docker start content-bot-v3

# 重启容器
docker restart content-bot-v3

# 删除容器
docker rm content-bot-v3

# 删除镜像
docker rmi content-bot-v3:latest
```

### 3. 更新容器
```bash
# 停止并删除旧容器
docker-compose down

# 拉取最新镜像
docker pull your-dockerhub-username/content-bot-v3:latest

# 启动新容器
docker-compose up -d

# 或者使用 Docker Compose 更新
docker-compose pull
docker-compose up -d
```

---

## Docker Compose 完整示例

### docker-compose.yml
```yaml
version: '3.8'

services:
  content-bot:
    image: kobex95/content-bot-v3:latest
    container_name: content-bot-v3
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./sessions:/app/sessions
      - ./downloads:/app/downloads
      - ./config.py:/app/config.py:ro
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "pgrep", "-f", "python"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### .env 文件
```env
# Telegram API 配置
API_ID=12345678
API_HASH=your_api_hash_here
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz

# 用户配置
OWNER_ID=123456789
CHANNEL_ID=-1001234567890
LOG_GROUP=-1001234567890

# 数据库配置
MONGO_DB=mongodb+srv://user:pass@cluster.mongodb.net/bot

# 可选配置
STRING=
FREEMIUM_LIMIT=0
PREMIUM_LIMIT=500
YT_COOKIES=
INSTA_COOKIES=
WEBSITE_URL=
AD_API=

# 加密配置
MASTER_KEY=gK8HzLfT9QpViJcYeB5wRa3DmN7P2xUq
IV_KEY=s7Yx5CpVmE3F
```

---

## 常见问题

### 1. 构建失败
```bash
# 查看详细错误信息
docker build --no-cache -t content-bot-v3:latest . 2>&1 | tee build.log

# 检查 Dockerfile 语法
docker build --check -f Dockerfile .
```

### 2. 容器无法启动
```bash
# 查看容器日志
docker logs content-bot-v3

# 进入容器检查
docker exec -it content-bot-v3 /bin/bash

# 检查环境变量
docker exec content-bot-v3 env

# 检查文件是否存在
docker exec content-bot-v3 ls -la /app
```

### 3. 权限问题
```bash
# 给予正确的文件权限
chmod +x deploy.sh
chmod +x update.sh

# 挂载目录权限
sudo chown -R 1000:1000 ./sessions
sudo chown -R 1000:1000 ./downloads
```

### 4. 内存不足
```bash
# 限制容器内存使用
docker run -d \
  --name content-bot-v3 \
  --memory="2g" \
  --memory-swap="2g" \
  your-dockerhub-username/content-bot-v3:latest
```

### 5. 网络问题
```bash
# 使用 host 网络模式
docker run -d \
  --name content-bot-v3 \
  --network host \
  your-dockerhub-username/content-bot-v3:latest
```

### 6. 清理未使用的资源
```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的容器
docker container prune

# 清理未使用的卷
docker volume prune

# 清理所有未使用的资源
docker system prune -a
```

---

## 最佳实践

### 1. 使用多阶段构建（优化镜像大小）
```dockerfile
# 构建阶段
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# 运行阶段
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python3", "main.py"]
```

### 2. 使用 .dockerignore
创建 `.dockerignore` 文件：
```
.git
.gitignore
.env
.env.example
__pycache__
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info
dist
build
sessions/
downloads/
*.log
.vscode
.idea
本地化修改说明.md
Docker部署说明.md
```

### 3. 定期更新镜像
```bash
# 更新镜像脚本
docker pull your-dockerhub-username/content-bot-v3:latest
docker-compose down
docker-compose up -d
```

### 4. 备份重要数据
```bash
# 备份会话数据
docker cp content-bot-v3:/app/sessions ./backup/sessions

# 备份数据库（如果使用 MongoDB 容器）
docker exec mongodb mongodump --out /backup
```

---

## 总结

### 快速部署流程
1. 配置 `.env` 文件
2. 构建 Docker 镜像：`docker build -t content-bot-v3:latest .`
3. 登录 Docker Hub：`docker login`
4. 标记镜像：`docker tag content-bot-v3:latest your-dockerhub-username/content-bot-v3:latest`
5. 推送镜像：`docker push your-dockerhub-username/content-bot-v3:latest`
6. 在服务器上拉取：`docker pull your-dockerhub-username/content-bot-v3:latest`
7. 运行容器：`docker-compose up -d`

### 有用的命令速查
```bash
# 构建镜像
docker build -t content-bot-v3:latest .

# 运行容器
docker run -d --name content-bot-v3 --restart unless-stopped content-bot-v3:latest

# 查看日志
docker logs -f content-bot-v3

# 停止容器
docker stop content-bot-v3

# 删除容器
docker rm content-bot-v3

# 推送镜像
docker push your-dockerhub-username/content-bot-v3:latest

# 拉取镜像
docker pull your-dockerhub-username/content-bot-v3:latest
```

---

**文档版本**: 1.0
**最后更新**: 2026年1月8日
**适用版本**: Content-Bot-v3
