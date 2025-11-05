#!/bin/bash

# ============================================
# No-Code Architects Toolkit - 腾讯云COS一键部署脚本
# ============================================
# 
# 使用方法:
#   curl -fsSL https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-tencent-cos.sh | bash
#
# 或者下载后执行:
#   wget https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-tencent-cos.sh
#   chmod +x deploy-vps-tencent-cos.sh
#   ./deploy-vps-tencent-cos.sh
#
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示欢迎信息
echo ""
echo "============================================"
echo "  No-Code Architects Toolkit"
echo "  腾讯云COS一键部署脚本"
echo "============================================"
echo ""

# 检查是否为root用户
if [ "$EUID" -eq 0 ]; then 
    print_warning "检测到root用户，建议使用普通用户运行此脚本"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查操作系统
print_info "检查操作系统..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    print_success "操作系统: $PRETTY_NAME"
else
    print_error "无法检测操作系统"
    exit 1
fi

if [[ "$OS" != "ubuntu" ]] && [[ "$OS" != "debian" ]]; then
    print_warning "此脚本主要针对Ubuntu/Debian系统，其他系统可能需要手动调整"
fi

# 检查Docker是否已安装
print_info "检查Docker安装状态..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker已安装: $DOCKER_VERSION"
else
    print_info "Docker未安装，开始安装..."
    
    # 更新包索引
    sudo apt-get update
    
    # 安装依赖
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # 添加Docker官方GPG密钥
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/${OS}/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # 设置仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${OS} \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    
    print_success "Docker安装完成"
fi

# 检查Docker Compose
if docker compose version &> /dev/null; then
    print_success "Docker Compose已安装"
else
    print_error "Docker Compose未安装，请手动安装"
    exit 1
fi

# 创建项目目录
print_info "创建项目目录..."
PROJECT_DIR="$HOME/nca-toolkit"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
print_success "项目目录: $PROJECT_DIR"

# 询问是否使用SSL
echo ""
print_info "是否配置SSL证书? (需要域名)"
echo "1) 是 - 使用Traefik自动获取Let's Encrypt证书"
echo "2) 否 - 仅使用HTTP (通过IP访问)"
read -p "请选择 (1/2): " ssl_choice

if [ "$ssl_choice" = "1" ]; then
    USE_SSL=true
    echo ""
    read -p "请输入您的域名 (例: api.yourdomain.com): " APP_DOMAIN
    read -p "请输入SSL证书邮箱: " SSL_EMAIL
    
    print_warning "请确保域名 $APP_DOMAIN 已解析到此服务器IP"
    read -p "按Enter继续..."
else
    USE_SSL=false
    APP_DOMAIN="localhost"
    SSL_EMAIL=""
fi

# 收集腾讯云COS配置
echo ""
print_info "请提供腾讯云COS配置信息"
echo "提示: 可在腾讯云控制台获取这些信息"
echo "  - 存储桶: https://console.cloud.tencent.com/cos5"
echo "  - 密钥: https://console.cloud.tencent.com/cam/capi"
echo ""

# 地域选择
echo "请选择腾讯云COS地域:"
echo "1) 广州 (ap-guangzhou)"
echo "2) 上海 (ap-shanghai)"
echo "3) 北京 (ap-beijing)"
echo "4) 成都 (ap-chengdu)"
echo "5) 深圳 (ap-shenzhen)"
echo "6) 香港 (ap-hongkong)"
echo "7) 新加坡 (ap-singapore)"
echo "8) 其他 (手动输入)"
read -p "请选择地域 (1-8): " region_choice

case $region_choice in
    1) S3_REGION="ap-guangzhou" ;;
    2) S3_REGION="ap-shanghai" ;;
    3) S3_REGION="ap-beijing" ;;
    4) S3_REGION="ap-chengdu" ;;
    5) S3_REGION="ap-shenzhen" ;;
    6) S3_REGION="ap-hongkong" ;;
    7) S3_REGION="ap-singapore" ;;
    8) 
        read -p "请输入地域代码 (例: ap-guangzhou): " S3_REGION
        ;;
    *) 
        print_error "无效选择"
        exit 1
        ;;
esac

S3_ENDPOINT_URL="https://cos.${S3_REGION}.myqcloud.com"

echo ""
read -p "请输入腾讯云SecretId (API密钥): " S3_ACCESS_KEY
read -p "请输入腾讯云SecretKey (API密钥): " S3_SECRET_KEY
read -p "请输入存储桶名称 (包含-APPID后缀): " S3_BUCKET_NAME

# 询问是否使用内网endpoint
echo ""
read -p "VPS是否与COS在同一地域? (使用内网可节省流量费) (y/n): " use_internal
if [[ $use_internal =~ ^[Yy]$ ]]; then
    S3_ENDPOINT_URL="https://cos.${S3_REGION}.tencentcos.cn"
    print_info "将使用内网endpoint: $S3_ENDPOINT_URL"
fi

# 生成API密钥
echo ""
print_info "生成API密钥..."
API_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
print_success "API密钥: $API_KEY"
print_warning "请妥善保存此密钥!"

# 询问性能配置
echo ""
CPU_CORES=$(nproc)
print_info "检测到CPU核心数: $CPU_CORES"
RECOMMENDED_WORKERS=$((CPU_CORES * 2))
read -p "设置Gunicorn Workers数量 (推荐: $RECOMMENDED_WORKERS): " GUNICORN_WORKERS
GUNICORN_WORKERS=${GUNICORN_WORKERS:-$RECOMMENDED_WORKERS}

read -p "设置请求超时时间(秒) (默认: 300): " GUNICORN_TIMEOUT
GUNICORN_TIMEOUT=${GUNICORN_TIMEOUT:-300}

read -p "设置最大队列长度 (默认: 10, 0=无限制): " MAX_QUEUE_LENGTH
MAX_QUEUE_LENGTH=${MAX_QUEUE_LENGTH:-10}

# 创建.env文件
print_info "创建配置文件..."
cat > .env << EOF
# ============================================
# No-Code Architects Toolkit Configuration
# 腾讯云COS配置
# 创建时间: $(date)
# ============================================

# 应用配置
APP_NAME=NCAToolkit
APP_DEBUG=false
EOF

if [ "$USE_SSL" = true ]; then
    cat >> .env << EOF
APP_DOMAIN=${APP_DOMAIN}
APP_URL=https://\${APP_DOMAIN}
SSL_EMAIL=${SSL_EMAIL}
EOF
fi

cat >> .env << EOF

# API密钥 (重要: 请妥善保管)
API_KEY=${API_KEY}

# 腾讯云COS存储配置
S3_ENDPOINT_URL=${S3_ENDPOINT_URL}
S3_ACCESS_KEY=${S3_ACCESS_KEY}
S3_SECRET_KEY=${S3_SECRET_KEY}
S3_BUCKET_NAME=${S3_BUCKET_NAME}
S3_REGION=${S3_REGION}

# 性能配置
GUNICORN_WORKERS=${GUNICORN_WORKERS}
GUNICORN_TIMEOUT=${GUNICORN_TIMEOUT}
MAX_QUEUE_LENGTH=${MAX_QUEUE_LENGTH}
LOCAL_STORAGE_PATH=/tmp
EOF

print_success "配置文件创建完成: .env"

# 创建docker-compose.yml
print_info "创建Docker Compose配置..."

if [ "$USE_SSL" = true ]; then
    # 使用Traefik的配置
    cat > docker-compose.yml << 'EOF'
services:
  traefik:
    image: "traefik:latest"
    restart: unless-stopped
    command:
      - "--api=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro
  
  ncat:
    image: stephengpope/no-code-architects-toolkit:latest
    env_file:
      - .env
    labels:
      - traefik.enable=true
      - traefik.http.routers.ncat.rule=Host(`${APP_DOMAIN}`)
      - traefik.http.routers.ncat.tls=true
      - traefik.http.routers.ncat.entrypoints=web,websecure
      - traefik.http.routers.ncat.tls.certresolver=mytlschallenge
      - traefik.http.services.ncat.loadbalancer.server.port=8080
    volumes:
      - storage:/tmp
      - logs:/app/logs
    restart: unless-stopped

volumes:
  traefik_data:
    driver: local
  storage:
    driver: local
  logs:
    driver: local
EOF
else
    # 简单HTTP配置
    cat > docker-compose.yml << 'EOF'
services:
  ncat:
    image: stephengpope/no-code-architects-toolkit:latest
    ports:
      - "8080:8080"
    env_file:
      - .env
    volumes:
      - storage:/tmp
      - logs:/app/logs
    restart: unless-stopped

volumes:
  storage:
    driver: local
  logs:
    driver: local
EOF
fi

print_success "Docker Compose配置创建完成"

# 启动服务
echo ""
print_info "准备启动服务..."
read -p "是否现在启动服务? (y/n): " start_now

if [[ $start_now =~ ^[Yy]$ ]]; then
    print_info "拉取Docker镜像..."
    docker compose pull
    
    print_info "启动服务..."
    docker compose up -d
    
    print_success "服务启动成功!"
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 10
    
    # 测试API
    print_info "测试API连接..."
    if [ "$USE_SSL" = true ]; then
        TEST_URL="https://${APP_DOMAIN}/v1/toolkit/test"
    else
        TEST_URL="http://localhost:8080/v1/toolkit/test"
    fi
    
    if curl -s -X POST "$TEST_URL" -H "X-API-Key: ${API_KEY}" | grep -q "success"; then
        print_success "API测试成功!"
    else
        print_warning "API测试失败，请查看日志: docker compose logs -f"
    fi
fi

# 显示总结
echo ""
echo "============================================"
echo "  部署完成!"
echo "============================================"
echo ""
print_success "项目目录: $PROJECT_DIR"
print_success "API密钥: $API_KEY"

if [ "$USE_SSL" = true ]; then
    print_success "API地址: https://${APP_DOMAIN}"
    echo ""
    echo "测试命令:"
    echo "  curl -X POST https://${APP_DOMAIN}/v1/toolkit/test \\"
    echo "    -H \"X-API-Key: ${API_KEY}\""
else
    print_success "API地址: http://$(curl -s ifconfig.me):8080"
    echo ""
    echo "测试命令:"
    echo "  curl -X POST http://localhost:8080/v1/toolkit/test \\"
    echo "    -H \"X-API-Key: ${API_KEY}\""
fi

echo ""
echo "常用命令:"
echo "  cd $PROJECT_DIR"
echo "  docker compose logs -f          # 查看日志"
echo "  docker compose restart          # 重启服务"
echo "  docker compose stop             # 停止服务"
echo "  docker compose up -d            # 启动服务"
echo "  docker compose pull && docker compose up -d  # 更新服务"
echo ""
echo "配置文件:"
echo "  .env                  # 环境变量配置"
echo "  docker-compose.yml    # Docker Compose配置"
echo ""
print_warning "重要: 请备份.env文件中的API密钥!"
echo ""
print_info "更多文档: https://github.com/stephengpope/no-code-architects-toolkit"
print_info "获取支持: https://www.skool.com/no-code-architects"
echo ""
