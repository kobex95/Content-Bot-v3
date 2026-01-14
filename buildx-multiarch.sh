#!/bin/bash

# Content-Bot 多架构构建脚本
# 使用 Docker Buildx 构建多架构镜像并推送到 Docker Hub

set -e

echo "🏗️ Content-Bot 多架构构建脚本"
echo "==================================="

# 配置变量
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-kobex95}"
IMAGE_NAME="content-bot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7}"

echo "📋 构建配置:"
echo "   Docker Hub 用户名: ${DOCKER_HUB_USERNAME}"
echo "   镜像名称: ${IMAGE_NAME}"
echo "   版本标签: ${VERSION}"
echo "   目标平台: ${PLATFORMS}"
echo "   完整镜像名: ${FULL_IMAGE_NAME}:${VERSION}"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

# 检查 buildx 插件
echo "🔧 检查 Docker Buildx..."
if ! docker buildx version &> /dev/null; then
    echo "❌ Docker Buildx 未安装或未启用"
    echo "请参考: https://docs.docker.com/buildx/working-with-buildx/"
    exit 1
fi

# 创建或使用 buildx 构建器
echo "🏗️ 设置构建器..."
BUILDER_NAME="content-bot-builder"

# 检查构建器是否已存在
if docker buildx ls | grep -q ${BUILDER_NAME}; then
    echo "✅ 使用现有构建器: ${BUILDER_NAME}"
    docker buildx use ${BUILDER_NAME}
else
    echo "🔨 创建新构建器: ${BUILDER_NAME}"
    docker buildx create --name ${BUILDER_NAME} --use --bootstrap
fi

# 检查构建器状态
echo "📊 构建器状态:"
docker buildx ls

# 检查 Docker Hub 登录状态
echo "🔐 检查 Docker Hub 登录状态..."
if ! docker info | grep -q "Username"; then
    echo "❌ 未登录 Docker Hub，请先登录:"
    echo "docker login"
    echo "或者使用: docker login -u ${DOCKER_HUB_USERNAME}"
    exit 1
fi

echo "✅ Docker Hub 登录状态正常"
echo ""

# 构建并推送多架构镜像
echo "🔨 构建多架构镜像..."
echo "目标平台: ${PLATFORMS}"

if [ "${DRY_RUN}" = "true" ]; then
    echo "🧪 干运行模式: 仅显示构建命令，不实际执行"
    echo "docker buildx build --platform ${PLATFORMS} -t ${FULL_IMAGE_NAME}:${VERSION} -t ${FULL_IMAGE_NAME}:latest --push ."
else
    echo "🚀 开始构建和推送..."
    docker buildx build \
        --platform ${PLATFORMS} \
        -t ${FULL_IMAGE_NAME}:${VERSION} \
        -t ${FULL_IMAGE_NAME}:latest \
        --push \
        .
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 多架构镜像构建和推送成功!"
    echo ""
    echo "🌐 Docker Hub 镜像地址:"
    echo "   https://hub.docker.com/r/${DOCKER_HUB_USERNAME}/${IMAGE_NAME}"
    echo ""
    echo "📋 支持的架构:"
    for platform in ${PLATFORMS//,/ }; do
        echo "   - ${platform}"
    done
    echo ""
    echo "🚀 使用命令:"
    echo "   docker run -d --name content-bot -p 5000:5000 ${FULL_IMAGE_NAME}:${VERSION}"
    echo ""
    echo "🔍 查看镜像信息:"
    echo "   docker buildx imagetools inspect ${FULL_IMAGE_NAME}:${VERSION}"
else
    echo "❌ 多架构镜像构建失败!"
    exit 1
fi
