#!/bin/bash

# Content-Bot Docker 部署脚本
# 用于一键部署 Content-Bot 到 Docker 环境

set -e

echo "🚀 Content-Bot Docker 部署脚本"
echo "=================================="

# 检查参数
ENVIRONMENT=${1:-production}
echo "📋 部署环境: ${ENVIRONMENT}"

# 检查必要文件
if [ ! -f ".env" ] && [ ! -f ".env.production" ]; then
    echo "❌ 未找到环境配置文件"
    if [ "$ENVIRONMENT" = "production" ]; then
        echo "请创建 .env.production 文件"
    else
        echo "请创建 .env 文件"
    fi
    exit 1
fi

# 检查 Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装"
    exit 1
fi

# 选择 compose 文件
COMPOSE_FILE="docker-compose.yml"
if [ "$ENVIRONMENT" = "development" ]; then
    COMPOSE_FILE="docker-compose.dev.yml"
elif [ "$ENVIRONMENT" = "production" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
fi

echo "📋 使用配置文件: ${COMPOSE_FILE}"

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose -f ${COMPOSE_FILE} down || true

# 拉取最新代码
echo "📥 拉取最新代码..."
git pull origin master

# 构建镜像
echo "🔨 构建 Docker 镜像..."
docker-compose -f ${COMPOSE_FILE} build

# 启动服务
echo "🚀 启动服务..."
docker-compose -f ${COMPOSE_FILE} up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose -f ${COMPOSE_FILE} ps

# 显示日志
echo "📋 显示服务日志:"
docker-compose -f ${COMPOSE_FILE} logs --tail=20

echo "✅ 部署完成!"
echo "🌐 访问地址: http://localhost:5000"
echo "📋 查看日志: docker-compose -f ${COMPOSE_FILE} logs -f"
echo "🛑 停止服务: docker-compose -f ${COMPOSE_FILE} down"
