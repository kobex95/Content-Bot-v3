#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════════
# ░ Content-Bot-v3 自动部署脚本
# ════════════════════════════════════════════════════════════════════════════════

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检查 root 权限
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要使用 root 用户运行此脚本"
        exit 1
    fi
}

# 检查系统
check_system() {
    log_info "检查系统环境..."

    if [[ -f /etc/debian_version ]]; then
        OS="debian"
    elif [[ -f /etc/redhat-release ]]; then
        OS="redhat"
    else
        log_error "不支持的操作系统"
        exit 1
    fi

    log_success "检测到操作系统: $OS"
}

# 安装系统依赖
install_dependencies() {
    log_info "安装系统依赖..."

    if [[ "$OS" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y \
            git \
            python3 \
            python3-pip \
            python3-venv \
            ffmpeg \
            curl \
            wget \
            build-essential \
            libopus-dev \
            libffi-dev \
            libsodium-dev \
            tmux \
            htop
    else
        sudo yum install -y \
            git \
            python3 \
            python3-pip \
            python3-venv \
            ffmpeg \
            curl \
            wget \
            gcc \
            make \
            opus-devel \
            libffi-devel \
            libsodium-devel \
            tmux \
            htop
    fi

    log_success "系统依赖安装完成"
}

# 检查 FFmpeg
check_ffmpeg() {
    log_info "检查 FFmpeg..."

    if ! command -v ffmpeg &> /dev/null; then
        log_error "FFmpeg 未安装"
        exit 1
    fi

    log_success "FFmpeg 已安装: $(ffmpeg -version | head -n 1)"
}

# 安装 Python 依赖
install_python_deps() {
    log_info "创建 Python 虚拟环境..."

    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
        log_success "虚拟环境创建完成"
    else
        log_info "虚拟环境已存在"
    fi

    log_info "激活虚拟环境..."
    source venv/bin/activate

    log_info "升级 pip..."
    pip install --upgrade pip setuptools wheel

    log_info "安装 Python 依赖..."
    pip install -r requirements.txt

    log_success "Python 依赖安装完成"
}

# 检查环境变量
check_env() {
    log_info "检查环境变量配置..."

    if [[ ! -f ".env" ]]; then
        log_warning ".env 文件不存在,从 .env.example 复制..."

        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            log_warning "请编辑 .env 文件并配置必需的环境变量"
            log_warning "编辑完成后重新运行此脚本"
            exit 1
        else
            log_error ".env.example 文件不存在"
            exit 1
        fi
    fi

    # 检查必需的环境变量
    source .env

    if [[ -z "$API_ID" ]] || [[ "$API_ID" == "your_api_id_here" ]]; then
        log_error "请在 .env 文件中配置 API_ID"
        exit 1
    fi

    if [[ -z "$API_HASH" ]] || [[ "$API_HASH" == "your_api_hash_here" ]]; then
        log_error "请在 .env 文件中配置 API_HASH"
        exit 1
    fi

    if [[ -z "$BOT_TOKEN" ]] || [[ "$BOT_TOKEN" == "your_bot_token_here" ]]; then
        log_error "请在 .env 文件中配置 BOT_TOKEN"
        exit 1
    fi

    if [[ -z "$MONGO_DB" ]] || [[ "$MONGO_DB" == "mongodb+srv://" ]]; then
        log_error "请在 .env 文件中配置 MONGO_DB"
        exit 1
    fi

    log_success "环境变量配置检查通过"
}

# 创建日志目录
create_log_dir() {
    log_info "创建日志目录..."

    mkdir -p logs

    log_success "日志目录创建完成"
}

# 创建 systemd 服务
create_systemd_service() {
    log_info "创建 systemd 服务..."

    CURRENT_DIR=$(pwd)
    CURRENT_USER=$(whoami)

    sudo tee /etc/systemd/system/content-bot.service > /dev/null <<EOF
[Unit]
Description=Content Bot V3 Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR
Environment="PATH=$CURRENT_DIR/venv/bin"
ExecStart=$CURRENT_DIR/venv/bin/python $CURRENT_DIR/main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable content-bot.service

    log_success "systemd 服务创建完成"
}

# 启动服务
start_service() {
    log_info "启动 Content-Bot-v3 服务..."

    sudo systemctl start content-bot.service

    sleep 3

    if systemctl is-active --quiet content-bot.service; then
        log_success "服务启动成功!"
        log_info "服务状态: $(sudo systemctl status content-bot.service | head -n 3)"
    else
        log_error "服务启动失败!"
        log_info "查看日志: sudo journalctl -u content-bot.service -n 50"
        exit 1
    fi
}

# 显示管理命令
show_management_commands() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${GREEN}服务管理命令${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo "查看服务状态:"
    echo "  sudo systemctl status content-bot.service"
    echo ""
    echo "启动服务:"
    echo "  sudo systemctl start content-bot.service"
    echo ""
    echo "停止服务:"
    echo "  sudo systemctl stop content-bot.service"
    echo ""
    echo "重启服务:"
    echo "  sudo systemctl restart content-bot.service"
    echo ""
    echo "查看实时日志:"
    echo "  sudo journalctl -u content-bot.service -f"
    echo ""
    echo "查看最近 50 行日志:"
    echo "  sudo journalctl -u content-bot.service -n 50"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${BLUE}    Content-Bot-v3 自动部署脚本${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""

    check_root
    check_system
    install_dependencies
    check_ffmpeg
    install_python_deps
    check_env
    create_log_dir
    create_systemd_service
    start_service
    show_management_commands

    echo ""
    log_success "部署完成! 🎉"
    echo ""
}

# 运行主函数
main "$@"
