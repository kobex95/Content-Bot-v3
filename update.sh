#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════════
# ░ Content-Bot-v3 更新脚本
# ════════════════════════════════════════════════════════════════════════════════

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 停止服务
stop_service() {
    log_info "停止服务..."
    sudo systemctl stop content-bot.service
    log_success "服务已停止"
}

# 拉取最新代码
pull_latest() {
    log_info "拉取最新代码..."

    git fetch origin
    git pull origin main

    log_success "代码更新完成"
}

# 更新依赖
update_dependencies() {
    log_info "更新 Python 依赖..."

    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    log_success "依赖更新完成"
}

# 启动服务
start_service() {
    log_info "启动服务..."
    sudo systemctl start content-bot.service

    sleep 3

    if systemctl is-active --quiet content-bot.service; then
        log_success "服务启动成功!"
    else
        log_error "服务启动失败!"
        sudo journalctl -u content-bot.service -n 50
        exit 1
    fi
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${BLUE}    Content-Bot-v3 更新脚本${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""

    stop_service
    pull_latest
    update_dependencies
    start_service

    echo ""
    log_success "更新完成! 🎉"
    echo ""
    echo "查看日志: sudo journalctl -u content-bot.service -f"
    echo ""
}

main "$@"
