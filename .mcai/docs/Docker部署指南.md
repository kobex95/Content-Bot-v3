# Content-Bot Docker 部署指南

本文档介绍如何使用 Docker 容器化部署 Content-Bot Telegram 机器人。

## 🐳 快速开始

### 前置条件

1. **安装 Docker**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo usermod -aG docker $USER
   
   # CentOS/RHEL
   sudo yum install -y docker
   sudo systemctl start docker
   sudo systemctl enable docker
   
   # macOS
   # 下载并安装 Docker Desktop
   ```

2. **安装 Docker Compose**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install -y docker-compose
   
   # 其他系统
   # 参考: https://docs.docker.com/compose/install/
   ```

### 一键部署

```bash
# 克隆仓库
git clone https://github.com/your-repo/content-bot.git
cd content-bot

# 复制环境配置文件
cp .env.example .env

# 编辑环境配置
nano .env

# 执行部署脚本
./deploy-docker.sh production
```

## 📋 环境配置

### 必需配置项

在 `.env` 文件中配置以下必需参数：

```bash
# Telegram API 配置
API_ID=your_api_id_here
API_HASH=your_api_hash_here
BOT_TOKEN=your_bot_token_here

# 数据库配置
MONGO_DB=mongodb+srv://username:password@cluster.mongodb.net/telegram_downloader
DB_NAME=telegram_downloader

# 管理员配置
OWNER_ID=123456789 987654321
LOG_GROUP=-1001234567890
FORCE_SUB=-1001234567890
```

### 安全配置

```bash
# 加密密钥（强烈建议修改默认值）
MASTER_KEY=your_random_32_char_key_here
IV_KEY=your_random_16_char_key_here
```

生成随机密钥：
```bash
# 生成 Master Key
openssl rand -hex 32

# 生成 IV Key
openssl rand -hex 8
```

## 🏗️ 部署方式

### 1. 开发环境部署

```bash
# 使用开发配置文件
docker-compose -f docker-compose.dev.yml up -d

# 或者使用脚本
./deploy-docker.sh development
```

开发环境特点：
- 挂载源代码目录支持热重载
- 启用 Flask 调试模式
- 更详细的日志输出

### 2. 生产环境部署

```bash
# 使用生产配置文件
docker-compose -f docker-compose.prod.yml up -d

# 或者使用脚本
./deploy-docker.sh production
```

生产环境特点：
- 资源限制配置
- 自动重启策略
- 包含 Nginx 反向代理
- SSL 支持

### 3. 简单部署

```bash
# 仅运行主容器
docker-compose up -d

# 或者手动运行
docker run -d \
  --name content-bot \
  -p 5000:5000 \
  --env-file .env \
  -v $(pwd)/sessions:/app/sessions \
  -v $(pwd)/logs:/app/logs \
  content-bot:latest
```

## 📁 目录结构

```
content-bot/
├── Dockerfile                 # Docker 镜像构建文件
├── docker-compose.yml          # 标准部署配置
├── docker-compose.dev.yml      # 开发环境配置
├── docker-compose.prod.yml     # 生产环境配置
├── .dockerignore              # Docker 忽略文件
├── .env.example               # 环境配置示例
├── build.sh                   # 镜像构建脚本
├── deploy-docker.sh           # 一键部署脚本
├── src/                       # 应用源代码
├── plugins/                   # 插件目录
├── utils/                     # 工具模块
├── templates/                 # HTML 模板
├── sessions/                  # 会话文件（挂载卷）
└── logs/                      # 日志文件（挂载卷）
```

## 🔧 常用命令

### 容器管理

```bash
# 查看容器状态
docker-compose ps

# 查看容器日志
docker-compose logs -f content-bot

# 停止容器
docker-compose down

# 重启容器
docker-compose restart

# 进入容器
docker-compose exec content-bot bash
```

### 镜像管理

```bash
# 构建镜像
./build.sh
# 或者
docker build -t content-bot:latest .

# 查看镜像
docker images content-bot

# 删除镜像
docker rmi content-bot:latest
```

### 数据管理

```bash
# 备份会话文件
tar -czf sessions-backup-$(date +%Y%m%d).tar.gz sessions/

# 恢复会话文件
tar -xzf sessions-backup-YYYYMMDD.tar.gz

# 查看日志文件
tail -f logs/app.log
```

## 🔍 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   # 检查日志
   docker-compose logs content-bot
   
   # 检查环境配置
   docker-compose exec content-bot env | grep -E '(API_|BOT_|MONGO_)'
   ```

2. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tlnp | grep 5000
   
   # 修改端口映射
   # 在 docker-compose.yml 中修改 ports 配置
   ```

3. **数据库连接失败**
   ```bash
   # 测试数据库连接
   docker-compose exec content-bot python3 -c "
   from pymongo import MongoClient
   client = MongoClient('${MONGO_DB}')
   print('Database connection successful')
   "
   ```

4. **权限问题**
   ```bash
   # 修复目录权限
   sudo chown -R 1000:1000 sessions/ logs/
   ```

### 健康检查

```bash
# 检查容器健康状态
docker inspect --format='{{json .State.Health}}' content-bot

# 手动健康检查
curl -f http://localhost:5000/ || echo "Health check failed"
```

## 🔄 更新部署

### 自动更新

```bash
# 使用部署脚本自动更新
./deploy-docker.sh production
```

### 手动更新

```bash
# 拉取最新代码
git pull origin master

# 重新构建镜像
docker-compose build --no-cache

# 重启服务
docker-compose up -d
```

## 📊 监控和日志

### 日志管理

```bash
# 查看实时日志
docker-compose logs -f --tail=100

# 查看特定时间段日志
docker-compose logs --since="2024-01-01T00:00:00" --until="2024-01-02T00:00:00"

# 导出日志
docker-compose logs > content-bot-$(date +%Y%m%d).log
```

### 性能监控

```bash
# 查看容器资源使用情况
docker stats content-bot

# 查看磁盘使用情况
docker system df

# 清理未使用的资源
docker system prune -f
```

## 🔒 安全建议

1. **网络安全**
   - 在生产环境中使用反向代理
   - 配置防火墙规则
   - 使用 HTTPS 加密传输

2. **密钥管理**
   - 不要在镜像中包含敏感信息
   - 使用环境变量传递密钥
   - 定期轮换 API 密钥

3. **访问控制**
   - 限制容器的网络访问
   - 使用非 root 用户运行容器
   - 定期更新基础镜像

## 📚 相关文档

- [项目文档](./0.INDEX.md)
- [架构设计](./1.ARCHITECTURE.md)
- [开发者指南](./3.DEVELOPER_GUIDE.md)
- [原始部署文档](../../Docker部署说明.md)

## 🆘 获取帮助

如果在部署过程中遇到问题：

1. 检查本文档的故障排除部分
2. 查看项目 Issue 页面
3. 联系技术支持: [Admin Contact](../config.py#ADMIN_CONTACT)
