#!/bin/bash

# Content-Bot Docker 构建脚本
# 用于构建和部署 Content-Bot Docker 镜像

set -e

echo "🐳 Content-Bot Docker 构建脚本"
echo "================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    echo "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y docker.io"
    echo "CentOS/RHEL: sudo yum install -y docker"
    echo "macOS: 下载 Docker Desktop"
    exit 1
fi

# 设置变量
IMAGE_NAME="content-bot"
VERSION="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

echo "📦 构建镜像: ${FULL_IMAGE_NAME}"

# 构建 Docker 镜像
docker build -t ${FULL_IMAGE_NAME} .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功!"
    echo "📋 镜像信息:"
    docker images ${IMAGE_NAME}
    
    echo "\n🚀 运行命令:"
    echo "docker run -d --name content-bot -p 5000:5000 ${FULL_IMAGE_NAME}"
    
    echo "\n🐙 使用 docker-compose:"
    echo "docker-compose up -d"
else
    echo "❌ 镜像构建失败!"
    exit 1
fi
