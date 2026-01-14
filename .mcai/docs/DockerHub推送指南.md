# Content-Bot Docker Hub 推送指南

本文档介绍如何将 Content-Bot Docker 镜像构建并推送到 Docker Hub，以及如何使用多架构构建支持。

## 🐳 快速开始

### 前置条件

1. **Docker Hub 账户**
   - 在 [Docker Hub](https://hub.docker.com/) 注册账户
   - 创建存储库（Repository）

2. **本地 Docker 安装**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo usermod -aG docker $USER
   
   # CentOS/RHEL
   sudo yum install -y docker
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Docker Buildx（多架构构建）**
   ```bash
   # 安装 buildx 插件
   docker buildx install
   
   # 验证安装
   docker buildx version
   ```

### 登录 Docker Hub

```bash
# 交互式登录
docker login

# 或者指定用户名登录
docker login -u your-username

# 输入密码完成认证
```

## 🚀 推送方法

### 方法 1: 使用自动化脚本（推荐）

#### 单架构推送

```bash
# 使用默认配置推送
./push-to-hub.sh

# 自定义配置
export DOCKER_HUB_USERNAME="your-username"
export VERSION="v1.0.0"
./push-to-hub.sh
```

#### 多架构推送

```bash
# 构建多架构镜像
./buildx-multiarch.sh

# 自定义平台
export PLATFORMS="linux/amd64,linux/arm64"
./buildx-multiarch.sh

# 干运行模式（仅测试）
export DRY_RUN="true"
./buildx-multiarch.sh
```

### 方法 2: 手动构建推送

#### 构建镜像

```bash
# 设置变量
DOCKER_HUB_USERNAME="your-username"
IMAGE_NAME="content-bot"
VERSION="latest"

# 构建镜像
docker build -t ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION} .

# 同时打 latest 标签
docker tag ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION} ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest
```

#### 推送镜像

```bash
# 推送版本标签
docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}

# 推送 latest 标签
docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest
```

### 方法 3: 多架构手动构建

```bash
# 创建 buildx 构建器
docker buildx create --name multiarch-builder --use

# 构建并推送多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t your-username/content-bot:latest \
  -t your-username/content-bot:v1.0.0 \
  --push \
  .
```

## 🔧 配置选项

### 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `DOCKER_HUB_USERNAME` | `kobex95` | Docker Hub 用户名 |
| `IMAGE_NAME` | `content-bot` | 镜像名称 |
| `VERSION` | `latest` | 版本标签 |
| `PLATFORMS` | `linux/amd64,linux/arm64,linux/arm/v7` | 目标平台 |
| `DRY_RUN` | `false` | 干运行模式 |

### 平台支持

| 平台 | 架构 | 描述 |
|------|------|------|
| `linux/amd64` | x86_64 | 标准服务器架构 |
| `linux/arm64` | ARM64 | 现代 ARM 设备 |
| `linux/arm/v7` | ARMv7 | 树莓派等设备 |
| `linux/arm/v6` | ARMv6 | 老版本 ARM 设备 |

## 🔄 CI/CD 自动化

### GitHub Actions 配置

项目已配置 GitHub Actions 工作流，自动在以下情况构建和推送镜像：

1. **推送到主分支**: 自动构建并推送到 latest 标签
2. **推送版本标签**: 构建并推送到对应版本标签
3. **手动触发**: 支持手动触发构建

#### 设置 Secrets

在 GitHub 仓库设置中添加以下 Secrets：

```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password-or-token
```

#### 工作流特性

- ✅ 多架构构建支持（AMD64、ARM64、ARMv7）
- ✅ 自动标签管理
- ✅ 构建缓存优化
- ✅ SBOM 生成
- ✅ 测试阶段验证

### 触发构建

```bash
# 推送代码到主分支（自动触发）
git push origin master

# 创建版本标签（自动触发）
git tag v1.0.0
git push origin v1.0.0

# 手动触发（在 GitHub Actions 页面）
# 1. 进入 Actions 页面
# 2. 选择 "Publish Docker Image" 工作流
# 3. 点击 "Run workflow"
```

## 📋 镜像使用

### 基本使用

```bash
# 拉取镜像
docker pull your-username/content-bot:latest

# 运行容器
docker run -d \
  --name content-bot \
  -p 5000:5000 \
  --env-file .env \
  your-username/content-bot:latest
```

### Docker Compose 使用

```yaml
version: '3.8'

services:
  content-bot:
    image: your-username/content-bot:latest
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

### 多架构部署

```bash
# 查看镜像支持的架构
docker buildx imagetools inspect your-username/content-bot:latest

# 在不同架构上运行
# AMD64 服务器
docker run -d --name content-bot-amd64 your-username/content-bot:latest

# ARM64 设备
docker run -d --name content-bot-arm64 your-username/content-bot:latest

# ARMv7 设备（如树莓派）
docker run -d --name content-bot-armv7 your-username/content-bot:latest
```

## 🔍 验证和故障排除

### 验证镜像

```bash
# 检查镜像信息
docker images your-username/content-bot

# 检查镜像层结构
docker history your-username/content-bot:latest

# 检查镜像元数据
docker inspect your-username/content-bot:latest
```

### 测试镜像

```bash
# 运行测试容器
docker run --rm -it \
  --env-file .env \
  your-username/content-bot:latest \
  python3 -c "import app; print('✅ 应用启动正常')"

# 检查健康状态
docker run -d --name test-bot \
  -p 5001:5000 \
  --env-file .env \
  your-username/content-bot:latest

sleep 10
curl -f http://localhost:5001/ && echo "✅ 健康检查通过"
docker stop test-bot && docker rm test-bot
```

### 常见问题

1. **推送权限错误**
   ```bash
   # 检查登录状态
   docker info | grep Username
   
   # 重新登录
   docker logout
   docker login -u your-username
   ```

2. **构建超时**
   ```bash
   # 增加构建超时
   docker buildx build \
     --timeout 3600 \
     --platform linux/amd64,linux/arm64 \
     -t your-username/content-bot:latest \
     --push \
     .
   ```

3. **多架构构建失败**
   ```bash
   # 检查 buildx 状态
   docker buildx ls
   
   # 重置构建器
   docker buildx rm multiarch-builder
   docker buildx create --name multiarch-builder --use
   ```

4. **镜像大小过大**
   ```bash
   # 使用多阶段构建优化
   # 已在 Dockerfile 中配置
   
   # 检查镜像大小
   docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" your-username/content-bot
   ```

## 📊 性能优化

### 构建优化

1. **使用构建缓存**
   ```bash
   # 启用 GitHub Actions 缓存
   # 已在工作流中配置
   
   # 本地缓存
   docker buildx build \
     --cache-from type=local,src=/tmp/.buildx-cache \
     --cache-to type=local,dest=/tmp/.buildx-cache \
     --platform linux/amd64,linux/arm64 \
     -t your-username/content-bot:latest \
     --push \
     .
   ```

2. **并行构建**
   ```bash
   # 设置并行工作线程
   docker buildx build \
     --build-arg BUILDKIT_INLINE_CACHE=1 \
     --builder multiarch-builder \
     --platform linux/amd64,linux/arm64 \
     -t your-username/content-bot:latest \
     --push \
     .
   ```

### 镜像优化

1. **减少层数**
   - 使用多阶段构建
   - 合并 RUN 指令
   - 使用 .dockerignore

2. **减小镜像大小**
   - 使用 alpine 基础镜像
   - 清理包管理器缓存
   - 移除不必要的依赖

## 🔒 安全最佳实践

### 镜像安全

1. **使用非 root 用户**
   ```dockerfile
   # 在 Dockerfile 中添加
   RUN adduser --disabled-password --gecos '' appuser
   USER appuser
   ```

2. **扫描安全漏洞**
   ```bash
   # 使用 Docker Scout
   docker scout cves your-username/content-bot:latest
   
   # 使用 Trivy
   trivy image your-username/content-bot:latest
   ```

3. **签名镜像**
   ```bash
   # 安装 Docker Content Trust
   export DOCKER_CONTENT_TRUST=1
   
   # 推送已签名镜像
   docker push your-username/content-bot:latest
   ```

### 访问控制

1. **私有仓库**
   ```bash
   # 推送到私有仓库
   docker push your-username/content-bot:latest
   
   # 配置访问权限
   # 在 Docker Hub 仓库设置中配置
   ```

2. **团队协作**
   ```bash
   # 创建 Docker Hub 组织
   # 在组织下创建仓库
   # 邀请团队成员
   ```

## 📈 监控和分析

### 镜像使用统计

```bash
# 查看拉取统计（Docker Hub 网页界面）
# https://hub.docker.com/r/your-username/content-bot

# 查看镜像大小变化
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" your-username/content-bot
```

### 构建监控

1. **GitHub Actions 监控**
   - 工作流运行历史
   - 构建时间和成功率
   - 错误日志分析

2. **本地构建监控**
   ```bash
   # 构建时间统计
   time docker build -t test:latest .
   
   # 资源使用监控
   docker stats
   ```

## 🔗 相关资源

- [Docker Hub 官方文档](https://docs.docker.com/docker-hub/)
- [Docker Buildx 文档](https://docs.docker.com/buildx/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [多架构构建最佳实践](https://docs.docker.com/buildx/working-with-buildx/)
- [Docker 安全最佳实践](https://docs.docker.com/develop/dev-best-practices/)

---

**维护者**: [devgagan](https://github.com/devgaganin)

**更新日期**: 2025-01-14
