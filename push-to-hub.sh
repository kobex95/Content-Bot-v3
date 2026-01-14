#!/bin/bash

# Content-Bot Docker Hub 推送脚本
# 用于构建和推送 Docker 镜像到 Docker Hub

set -e

echo "🐳 Content-Bot Docker Hub 推送脚本"
echo "====================================="

# 配置变量
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-kobex95}"
IMAGE_NAME="content-bot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
LATEST_IMAGE_NAME="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"

echo "📋 推送配置:"
echo "   Docker Hub 用户名: ${DOCKER_HUB_USERNAME}"
echo "   镜像名称: ${IMAGE_NAME}"
echo "   版本标签: ${VERSION}"
echo "   完整镜像名: ${FULL_IMAGE_NAME}"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    echo "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y docker.io"
    echo "CentOS/RHEL: sudo yum install -y docker"
    echo "macOS: 下载 Docker Desktop"
    exit 1
fi

# 检查是否已登录 Docker Hub
echo "🔐 检查 Docker Hub 登录状态..."
if ! docker info | grep -q "Username"; then
    echo "❌ 未登录 Docker Hub，请先登录:"
    echo "docker login"
    echo "或者使用: docker login -u ${DOCKER_HUB_USERNAME}"
    exit 1
fi

echo "✅ Docker Hub 登录状态正常"
echo ""

# 构建镜像
echo "🔨 构建 Docker 镜像..."
docker build -t ${FULL_IMAGE_NAME} -t ${LATEST_IMAGE_NAME} .

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败!"
    exit 1
fi

echo "✅ 镜像构建成功!"
echo ""

# 显示镜像信息
echo "📋 构建的镜像:"
docker images | grep ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}
echo ""

# 推送镜像
echo "📤 推送镜像到 Docker Hub..."

echo "📤 推送版本标签: ${FULL_IMAGE_NAME}"
docker push ${FULL_IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "❌ 镜像推送失败!"
    exit 1
fi

# 如果不是 latest 标签，也推送 latest
echo "📤 推送 latest 标签: ${LATEST_IMAGE_NAME}"
docker push ${LATEST_IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "❌ latest 标签推送失败!"
    exit 1
fi

echo ""
echo "✅ 镜像推送成功!"
echo ""
echo "🌐 Docker Hub 镜像地址:"
echo "   https://hub.docker.com/r/${DOCKER_HUB_USERNAME}/${IMAGE_NAME}"
echo ""
echo "🚀 使用命令:"
echo "   docker run -d --name content-bot -p 5000:5000 ${FULL_IMAGE_NAME}"
echo ""
echo "🐙 使用 docker-compose:"
echo "   image: ${FULL_IMAGE_NAME}"
echo ""
echo "📋 其他可用标签:"
echo "   ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"
if [ "${VERSION}" != "latest" ]; then
    echo "   ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
fi
