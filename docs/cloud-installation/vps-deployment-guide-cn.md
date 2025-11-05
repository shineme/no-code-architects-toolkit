# No-Code Architects Toolkit VPS 部署指南（中文）

本指南将帮助您在自己的VPS服务器上部署 No-Code Architects Toolkit API，支持源码和Docker两种部署方式，并详细说明如何配置腾讯云COS和阿里云OSS存储。

---

## 目录
1. [VPS性能要求](#vps性能要求)
2. [部署方式选择](#部署方式选择)
3. [Docker部署（推荐）](#docker部署推荐)
4. [源码部署](#源码部署)
5. [配置腾讯云COS](#配置腾讯云cos)
6. [配置阿里云OSS](#配置阿里云oss)
7. [性能优化建议](#性能优化建议)
8. [故障排查](#故障排查)

---

## VPS性能要求

### 最低配置（适合测试和轻量使用）
- **CPU**: 2核
- **内存**: 4GB RAM
- **存储**: 40GB SSD
- **带宽**: 5Mbps
- **操作系统**: Ubuntu 20.04/22.04 LTS 或 Debian 11+

### 推荐配置（适合生产环境）
- **CPU**: 4核或以上
- **内存**: 8GB RAM 或以上
- **存储**: 80GB+ SSD
- **带宽**: 10Mbps+
- **操作系统**: Ubuntu 22.04 LTS

### 高性能配置（处理大文件和高并发）
- **CPU**: 8核或以上
- **内存**: 16GB RAM 或以上
- **存储**: 100GB+ NVMe SSD
- **带宽**: 50Mbps+
- **操作系统**: Ubuntu 22.04 LTS

### 注意事项
- **视频处理**: 需要大量CPU资源，建议至少4核
- **AI转录/翻译**: Whisper模型需要至少4GB内存，推荐8GB+
- **并发处理**: 每增加2个并发任务，建议增加2GB内存和1个CPU核心
- **临时存储**: `/tmp`目录需要足够空间存储处理中的媒体文件，建议预留20-50GB

---

## 部署方式选择

### Docker部署（强烈推荐）
**优点**:
- ✅ 环境一致性，避免依赖问题
- ✅ 快速部署，5-10分钟即可完成
- ✅ 易于管理和更新
- ✅ 自带FFmpeg和所有依赖
- ✅ 支持自动SSL证书（使用Traefik）

**缺点**:
- ❌ 需要安装Docker（约1GB磁盘空间）
- ❌ 轻微的性能开销（约5-10%）

### 源码部署
**优点**:
- ✅ 更直接的系统访问
- ✅ 可能略好的性能
- ✅ 便于调试和开发

**缺点**:
- ❌ 需要手动安装大量依赖
- ❌ FFmpeg需要从源码编译（1-2小时）
- ❌ 环境配置复杂，容易出错
- ❌ 更新和维护麻烦

**建议**: 除非您有特殊需求或想参与开发，否则强烈推荐使用Docker部署。

---

## Docker部署（推荐）

### 步骤1: 准备VPS环境

```bash
# 更新系统包
sudo apt-get update && sudo apt-get upgrade -y

# 安装基本工具
sudo apt-get install -y curl wget git nano
```

### 步骤2: 安装Docker和Docker Compose

```bash
# 添加Docker官方GPG密钥
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 添加Docker仓库
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新APT包索引
sudo apt-get update

# 安装Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 验证安装
docker --version
docker compose version
```

### 步骤3: 创建项目目录

```bash
# 创建项目目录
mkdir -p ~/nca-toolkit
cd ~/nca-toolkit
```

### 步骤4: 创建docker-compose.yml

#### 方案A: 使用Traefik自动SSL（推荐）

如果您有域名并希望使用HTTPS：

```bash
nano docker-compose.yml
```

粘贴以下内容：

```yaml
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
```

#### 方案B: 简单HTTP部署（无SSL）

如果您只使用IP地址或内网部署：

```bash
nano docker-compose.yml
```

粘贴以下内容：

```yaml
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
```

### 步骤5: 创建环境变量文件

```bash
nano .env
```

根据您使用的存储服务，选择相应的配置：

#### 使用腾讯云COS（见下文详细配置）

```env
# 应用名称
APP_NAME=NCAToolkit

# 域名配置（如果使用Traefik SSL）
APP_DOMAIN=your-domain.com
APP_URL=https://${APP_DOMAIN}

# SSL配置（如果使用Traefik）
SSL_EMAIL=your-email@example.com

# API密钥（必填，自己设置）
API_KEY=your_secure_api_key_here

# 腾讯云COS配置
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=your_tencent_secret_id
S3_SECRET_KEY=your_tencent_secret_key
S3_BUCKET_NAME=your-bucket-name
S3_REGION=ap-guangzhou

# 性能调优（可选）
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
LOCAL_STORAGE_PATH=/tmp
```

#### 使用阿里云OSS（见下文详细配置）

```env
# 应用名称
APP_NAME=NCAToolkit

# 域名配置（如果使用Traefik SSL）
APP_DOMAIN=your-domain.com
APP_URL=https://${APP_DOMAIN}

# SSL配置（如果使用Traefik）
SSL_EMAIL=your-email@example.com

# API密钥（必填，自己设置）
API_KEY=your_secure_api_key_here

# 阿里云OSS配置
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=your_aliyun_access_key_id
S3_SECRET_KEY=your_aliyun_access_key_secret
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou

# 性能调优（可选）
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
LOCAL_STORAGE_PATH=/tmp
```

### 步骤6: 启动服务

```bash
# 拉取镜像并启动
docker compose up -d

# 查看日志
docker compose logs -f ncat

# 查看容器状态
docker compose ps
```

### 步骤7: 测试API

```bash
# 替换为您的实际域名或IP
curl -X POST http://localhost:8080/v1/toolkit/test \
  -H "X-API-Key: your_secure_api_key_here"

# 或使用域名（如果配置了SSL）
curl -X POST https://your-domain.com/v1/toolkit/test \
  -H "X-API-Key: your_secure_api_key_here"
```

如果返回类似以下JSON，说明部署成功：
```json
{
  "code": 200,
  "message": "success",
  "response": {
    "message": "NCA Toolkit API is working!"
  }
}
```

### Docker管理命令

```bash
# 重启服务
docker compose restart

# 停止服务
docker compose stop

# 启动服务
docker compose start

# 更新配置后重新创建容器
docker compose up -d --force-recreate

# 查看日志
docker compose logs -f ncat

# 进入容器shell
docker compose exec ncat bash

# 删除所有内容（危险！）
docker compose down -v
```

---

## 源码部署

### 步骤1: 安装系统依赖

```bash
# 更新系统
sudo apt-get update && sudo apt-get upgrade -y

# 安装Python 3.9+
sudo apt-get install -y python3.9 python3.9-pip python3.9-dev python3.9-venv

# 安装构建工具
sudo apt-get install -y build-essential wget git curl \
  ca-certificates fonts-liberation fontconfig

# 安装FFmpeg依赖库
sudo apt-get install -y \
  yasm cmake meson ninja-build nasm \
  libssl-dev libvpx-dev libx264-dev libx265-dev \
  libnuma-dev libmp3lame-dev libopus-dev libvorbis-dev \
  libtheora-dev libspeex-dev libfreetype6-dev \
  libfontconfig1-dev libgnutls28-dev libaom-dev \
  libdav1d-dev librav1e-dev libsvtav1enc-dev \
  libzimg-dev libwebp-dev pkg-config autoconf \
  automake libtool libfribidi-dev libharfbuzz-dev \
  libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
  libxcomposite1 libxrandr2 libxdamage1 libgbm1 \
  libasound2 libpangocairo-1.0-0 libpangoft2-1.0-0 libgtk-3-0
```

### 步骤2: 编译安装FFmpeg（需要1-2小时）

```bash
# 创建临时目录
mkdir -p ~/ffmpeg-build
cd ~/ffmpeg-build

# 安装SRT
git clone https://github.com/Haivision/srt.git
cd srt && mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
cd ../..

# 安装SVT-AV1
git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git
cd SVT-AV1 && git checkout v0.9.0 && cd Build
cmake ..
make -j$(nproc)
sudo make install
cd ../..

# 安装libvmaf
git clone https://github.com/Netflix/vmaf.git
cd vmaf/libvmaf
meson build --buildtype release
ninja -C build
sudo ninja -C build install
cd ../..

# 安装fdk-aac
git clone https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure
make -j$(nproc)
sudo make install
cd ..

# 安装libunibreak
git clone https://github.com/adah1972/libunibreak.git
cd libunibreak
./autogen.sh
./configure
make -j$(nproc)
sudo make install
cd ..

# 安装libass
git clone https://github.com/libass/libass.git
cd libass
autoreconf -i
./configure --enable-libunibreak
make -j$(nproc)
sudo make install
cd ..

# 更新动态链接库缓存
sudo ldconfig

# 编译FFmpeg
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
git checkout n7.0.2

PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig" \
CFLAGS="-I/usr/include/freetype2" \
LDFLAGS="-L/usr/lib/x86_64-linux-gnu" \
./configure --prefix=/usr/local \
    --enable-gpl \
    --enable-pthreads \
    --enable-neon \
    --enable-libaom \
    --enable-libdav1d \
    --enable-librav1e \
    --enable-libsvtav1 \
    --enable-libvmaf \
    --enable-libzimg \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libtheora \
    --enable-libspeex \
    --enable-libass \
    --enable-libfreetype \
    --enable-libharfbuzz \
    --enable-fontconfig \
    --enable-libsrt \
    --enable-filter=drawtext \
    --extra-cflags="-I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include" \
    --extra-ldflags="-L/usr/lib/x86_64-linux-gnu -lfreetype -lfontconfig" \
    --enable-gnutls

make -j$(nproc)
sudo make install
sudo ldconfig

# 验证安装
ffmpeg -version

# 清理临时文件
cd ~
rm -rf ~/ffmpeg-build
```

### 步骤3: 克隆项目并安装Python依赖

```bash
# 克隆项目
cd ~
git clone https://github.com/stephengpope/no-code-architects-toolkit.git
cd no-code-architects-toolkit

# 创建Python虚拟环境
python3.9 -m venv venv
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt
pip install openai-whisper playwright jsonschema

# 安装Playwright浏览器
playwright install chromium
```

### 步骤4: 配置环境变量

```bash
# 创建.env文件
nano .env
```

添加配置（参考Docker部署中的.env示例）

或直接导出环境变量：
```bash
export API_KEY="your_secure_api_key"
export S3_ENDPOINT_URL="https://cos.ap-guangzhou.myqcloud.com"
export S3_ACCESS_KEY="your_tencent_secret_id"
export S3_SECRET_KEY="your_tencent_secret_key"
export S3_BUCKET_NAME="your-bucket-name"
export S3_REGION="ap-guangzhou"
export GUNICORN_WORKERS=4
export GUNICORN_TIMEOUT=300
```

### 步骤5: 预下载Whisper模型

```bash
# 激活虚拟环境
source venv/bin/activate

# 创建缓存目录
export WHISPER_CACHE_DIR="/tmp/whisper_cache"
mkdir -p $WHISPER_CACHE_DIR

# 下载base模型
python -c "import whisper; whisper.load_model('base')"
```

### 步骤6: 启动应用

#### 方式A: 使用Gunicorn（生产环境）

```bash
source venv/bin/activate
gunicorn --bind 0.0.0.0:8080 \
  --workers 4 \
  --timeout 300 \
  --worker-class sync \
  --keep-alive 80 \
  --config gunicorn.conf.py \
  app:app
```

#### 方式B: 使用systemd服务（推荐）

创建服务文件：
```bash
sudo nano /etc/systemd/system/nca-toolkit.service
```

添加以下内容：
```ini
[Unit]
Description=No-Code Architects Toolkit API
After=network.target

[Service]
Type=notify
User=ubuntu
WorkingDirectory=/home/ubuntu/no-code-architects-toolkit
Environment="PATH=/home/ubuntu/no-code-architects-toolkit/venv/bin"
Environment="API_KEY=your_secure_api_key"
Environment="S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com"
Environment="S3_ACCESS_KEY=your_tencent_secret_id"
Environment="S3_SECRET_KEY=your_tencent_secret_key"
Environment="S3_BUCKET_NAME=your-bucket-name"
Environment="S3_REGION=ap-guangzhou"
Environment="GUNICORN_WORKERS=4"
Environment="GUNICORN_TIMEOUT=300"
Environment="WHISPER_CACHE_DIR=/tmp/whisper_cache"
ExecStart=/home/ubuntu/no-code-architects-toolkit/venv/bin/gunicorn \
  --bind 0.0.0.0:8080 \
  --workers 4 \
  --timeout 300 \
  --worker-class sync \
  --keep-alive 80 \
  --config gunicorn.conf.py \
  app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable nca-toolkit
sudo systemctl start nca-toolkit
sudo systemctl status nca-toolkit

# 查看日志
sudo journalctl -u nca-toolkit -f
```

### 步骤7: 配置Nginx反向代理（可选）

```bash
sudo apt-get install -y nginx

sudo nano /etc/nginx/sites-available/nca-toolkit
```

添加配置：
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }
}
```

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/nca-toolkit /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 配置腾讯云COS

### 步骤1: 创建存储桶

1. 登录 [腾讯云控制台](https://console.cloud.tencent.com/)
2. 进入 **对象存储 COS** 服务
3. 点击 **存储桶列表** -> **创建存储桶**
4. 配置：
   - **名称**: 例如 `nca-toolkit-bucket`（必须全局唯一）
   - **所属地域**: 选择离VPS最近的地域（如广州 `ap-guangzhou`）
   - **访问权限**: 选择 **公有读私有写**
   - **其他选项**: 保持默认

### 步骤2: 配置CORS（跨域资源共享）

1. 进入创建的存储桶
2. 点击 **安全管理** -> **跨域访问CORS设置**
3. 点击 **添加规则**：
   - **来源 Origin**: `*`
   - **操作 Methods**: 勾选 GET, PUT, POST, DELETE, HEAD
   - **Allow-Headers**: `*`
   - **Expose-Headers**: `ETag`
   - **超时 Max-Age**: `600`
4. 保存

### 步骤3: 获取访问密钥

1. 进入 [访问密钥管理](https://console.cloud.tencent.com/cam/capi)
2. 点击 **新建密钥**（如果还没有）
3. 记录：
   - **SecretId** -> 对应 `S3_ACCESS_KEY`
   - **SecretKey** -> 对应 `S3_SECRET_KEY`

### 步骤4: 配置环境变量

腾讯云COS的地域端点格式：
- 广州: `https://cos.ap-guangzhou.myqcloud.com`
- 上海: `https://cos.ap-shanghai.myqcloud.com`
- 北京: `https://cos.ap-beijing.myqcloud.com`
- 成都: `https://cos.ap-chengdu.myqcloud.com`
- 深圳: `https://cos.ap-shenzhen.myqcloud.com`
- 香港: `https://cos.ap-hongkong.myqcloud.com`
- 新加坡: `https://cos.ap-singapore.myqcloud.com`

更多地域参考：[腾讯云COS地域列表](https://cloud.tencent.com/document/product/436/6224)

在`.env`文件中添加：
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID_HERE
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=nca-toolkit-bucket-1234567890
S3_REGION=ap-guangzhou
```

**注意**:
- `S3_BUCKET_NAME` 需要使用完整的存储桶名称，格式为 `BucketName-APPID`
- 可以在存储桶列表中查看完整名称
- `S3_REGION` 使用地域简称（如 `ap-guangzhou`）

### 步骤5: 测试连接

```bash
# 重启服务（Docker）
docker compose restart ncat

# 或重启服务（源码部署）
sudo systemctl restart nca-toolkit

# 测试上传
curl -X POST http://localhost:8080/v1/s3/upload \
  -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "file_url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
  }'
```

---

## 配置阿里云OSS

### 步骤1: 创建存储桶（Bucket）

1. 登录 [阿里云控制台](https://www.aliyun.com/)
2. 进入 **对象存储OSS** 服务
3. 点击 **Bucket列表** -> **创建Bucket**
4. 配置：
   - **Bucket名称**: 例如 `nca-toolkit-bucket`（必须全局唯一，只能包含小写字母、数字、短横线）
   - **区域**: 选择离VPS最近的区域（如华东1杭州 `oss-cn-hangzhou`）
   - **存储类型**: 标准存储
   - **读写权限**: 公共读
   - **其他选项**: 保持默认

### 步骤2: 配置跨域访问（CORS）

1. 进入创建的Bucket
2. 点击 **权限管理** -> **跨域设置**
3. 点击 **创建规则**：
   - **来源**: `*`
   - **允许Methods**: 勾选 GET, POST, PUT, DELETE, HEAD
   - **允许Headers**: `*`
   - **暴露Headers**: `ETag`
   - **缓存时间(秒)**: `600`
4. 确定

### 步骤3: 创建访问密钥（AccessKey）

1. 鼠标悬停在右上角头像，点击 **AccessKey管理**
2. 点击 **创建AccessKey**
3. 完成身份验证后，记录：
   - **AccessKey ID** -> 对应 `S3_ACCESS_KEY`
   - **AccessKey Secret** -> 对应 `S3_SECRET_KEY`

**安全建议**: 使用RAM子账号的AccessKey，不要使用主账号密钥

创建RAM子账号：
1. 进入 **访问控制RAM** 服务
2. 点击 **用户** -> **创建用户**
3. 勾选 **编程访问**
4. 创建后，为用户添加 **AliyunOSSFullAccess** 权限
5. 使用子账号的AccessKey

### 步骤4: 配置环境变量

阿里云OSS的地域端点格式：
- 华东1(杭州): `https://oss-cn-hangzhou.aliyuncs.com`
- 华东2(上海): `https://oss-cn-shanghai.aliyuncs.com`
- 华北1(青岛): `https://oss-cn-qingdao.aliyuncs.com`
- 华北2(北京): `https://oss-cn-beijing.aliyuncs.com`
- 华北3(张家口): `https://oss-cn-zhangjiakou.aliyuncs.com`
- 华南1(深圳): `https://oss-cn-shenzhen.aliyuncs.com`
- 西南1(成都): `https://oss-cn-chengdu.aliyuncs.com`
- 香港: `https://oss-cn-hongkong.aliyuncs.com`
- 新加坡: `https://oss-ap-southeast-1.aliyuncs.com`

更多地域参考：[阿里云OSS访问域名](https://help.aliyun.com/document_detail/31837.html)

在`.env`文件中添加：
```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=YOUR_ALIYUN_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=nca-toolkit-bucket
S3_REGION=oss-cn-hangzhou
```

**注意**:
- `S3_BUCKET_NAME` 使用Bucket名称（不需要包含endpoint）
- `S3_REGION` 使用完整的地域标识符（如 `oss-cn-hangzhou`）
- 确保Bucket权限设置为"公共读"，否则生成的URL无法直接访问

### 步骤5: 测试连接

```bash
# 重启服务（Docker）
docker compose restart ncat

# 或重启服务（源码部署）
sudo systemctl restart nca-toolkit

# 测试上传
curl -X POST http://localhost:8080/v1/s3/upload \
  -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "file_url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
  }'
```

---

## 性能优化建议

### 1. Gunicorn Workers配置

根据服务器CPU核心数调整：
```env
# CPU核心数的2-4倍
GUNICORN_WORKERS=8

# 处理大文件需要更长超时
GUNICORN_TIMEOUT=600
```

公式：`GUNICORN_WORKERS = (2 × CPU核心数) + 1`

### 2. 队列长度限制

防止队列过载：
```env
# 0 = 无限制（不推荐）
# 10-20 适合中小型服务器
MAX_QUEUE_LENGTH=15
```

### 3. 临时存储优化

```env
# 使用独立的大容量分区
LOCAL_STORAGE_PATH=/data/nca-tmp
```

创建并挂载独立分区：
```bash
sudo mkdir -p /data/nca-tmp
sudo chmod 777 /data/nca-tmp

# 如果使用Docker，在docker-compose.yml中添加：
volumes:
  - /data/nca-tmp:/tmp
```

### 4. 系统级优化

增加文件描述符限制：
```bash
# 编辑limits配置
sudo nano /etc/security/limits.conf

# 添加以下行
* soft nofile 65536
* hard nofile 65536
```

增加TCP连接数：
```bash
sudo nano /etc/sysctl.conf

# 添加以下行
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 2048

# 应用配置
sudo sysctl -p
```

### 5. 日志管理

设置日志轮转：
```bash
sudo nano /etc/logrotate.d/nca-toolkit
```

添加：
```
/home/ubuntu/no-code-architects-toolkit/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

### 6. 监控和告警

安装监控工具：
```bash
# 安装htop
sudo apt-get install -y htop

# 安装iotop（磁盘IO监控）
sudo apt-get install -y iotop

# 查看实时资源使用
htop
```

使用Docker stats监控：
```bash
docker stats ncat
```

### 7. 缓存Whisper模型

预下载所有需要的模型：
```bash
# 进入容器
docker compose exec ncat bash

# 下载不同大小的模型
python -c "import whisper; whisper.load_model('tiny')"
python -c "import whisper; whisper.load_model('base')"
python -c "import whisper; whisper.load_model('small')"
python -c "import whisper; whisper.load_model('medium')"
# large模型需要10GB+ RAM
```

### 8. 网络优化

如果VPS和OSS/COS在同一地域，使用内网endpoint：

**腾讯云COS内网endpoint**:
```env
# 例如：广州内网
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
```

**阿里云OSS内网endpoint**:
```env
# 例如：杭州内网
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com
```

内网传输优势：
- ✅ 更快的上传/下载速度
- ✅ 不占用公网带宽
- ✅ 不产生流量费用（部分地域）

---

## 故障排查

### 问题1: Docker容器启动失败

```bash
# 查看容器日志
docker compose logs ncat

# 常见原因：
# 1. 端口被占用
sudo lsof -i :8080
sudo kill -9 <PID>

# 2. 环境变量错误
docker compose config

# 3. 镜像损坏
docker compose pull
docker compose up -d --force-recreate
```

### 问题2: API返回401 Unauthorized

检查API密钥配置：
```bash
# 查看环境变量
docker compose exec ncat env | grep API_KEY

# 确保.env文件中API_KEY正确
cat .env | grep API_KEY
```

### 问题3: 上传到COS/OSS失败

```bash
# 测试网络连接
curl -I https://cos.ap-guangzhou.myqcloud.com

# 检查存储配置
docker compose exec ncat env | grep S3_

# 验证密钥是否正确
# 腾讯云COS
curl -X GET https://cos.ap-guangzhou.myqcloud.com \
  -H "Authorization: your_secret_id"

# 阿里云OSS
curl -I https://your-bucket.oss-cn-hangzhou.aliyuncs.com
```

常见错误：
- **403 Forbidden**: 密钥错误或Bucket权限不足
- **404 Not Found**: Bucket名称或region错误
- **NoSuchBucket**: S3_BUCKET_NAME配置错误

### 问题4: 处理超时

增加超时时间：
```env
GUNICORN_TIMEOUT=900
```

或使用webhook模式（异步处理）：
```bash
curl -X POST http://localhost:8080/v1/media/transcribe \
  -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "media_url": "https://example.com/video.mp4",
    "webhook_url": "https://your-webhook.com/callback"
  }'
```

### 问题5: 内存不足

```bash
# 查看内存使用
free -h

# 查看容器内存使用
docker stats

# 添加swap（临时解决）
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久添加swap
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 问题6: 磁盘空间不足

```bash
# 查看磁盘使用
df -h

# 清理Docker缓存
docker system prune -a -f

# 清理旧日志
sudo find /var/log -type f -name "*.log" -mtime +7 -delete

# 清理临时文件
sudo rm -rf /tmp/*
```

### 问题7: FFmpeg编译失败（源码部署）

```bash
# 查看详细错误
./configure --help

# 常见缺失依赖
sudo apt-get install -y \
  libavcodec-dev libavformat-dev libswscale-dev \
  libavutil-dev libpostproc-dev

# 如果编译失败，考虑使用Docker部署
```

### 问题8: Whisper下载模型失败

```bash
# 手动设置代理（如果需要）
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port

# 手动下载模型
mkdir -p ~/.cache/whisper
cd ~/.cache/whisper
wget https://openaipublic.azureedge.net/main/whisper/models/base.pt
```

### 问题9: 查看详细日志

```bash
# Docker部署
docker compose logs -f --tail=100 ncat

# 源码部署
sudo journalctl -u nca-toolkit -f -n 100

# 进入容器查看Python日志
docker compose exec ncat bash
cd /tmp
ls -lh *.log
```

### 问题10: 端口被防火墙阻止

```bash
# Ubuntu/Debian - UFW
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

# CentOS/RHEL - firewalld
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 检查监听端口
sudo netstat -tlnp | grep 8080
```

### 调试技巧

启用调试模式：
```env
# 在.env中添加
APP_DEBUG=true
PYTHONUNBUFFERED=1
```

进入容器调试：
```bash
docker compose exec ncat bash

# 测试Python导入
python -c "import whisper; import ffmpeg; print('OK')"

# 测试FFmpeg
ffmpeg -version

# 测试网络
curl -I https://cos.ap-guangzhou.myqcloud.com
```

---

## 安全建议

### 1. 更改默认端口

```yaml
# docker-compose.yml
ports:
  - "8888:8080"  # 外部使用8888端口
```

### 2. 使用强API密钥

```bash
# 生成随机密钥
openssl rand -base64 32
```

### 3. 配置防火墙

```bash
# 只允许特定IP访问
sudo ufw allow from YOUR_IP to any port 8080
```

### 4. 定期更新

```bash
# Docker部署
docker compose pull
docker compose up -d

# 源码部署
cd ~/no-code-architects-toolkit
git pull
source venv/bin/activate
pip install -r requirements.txt --upgrade
sudo systemctl restart nca-toolkit
```

### 5. 备份配置

```bash
# 备份.env文件
cp .env .env.backup

# 备份Docker volumes
docker run --rm -v nca-toolkit_storage:/data \
  -v $(pwd):/backup ubuntu \
  tar czf /backup/storage-backup.tar.gz /data
```

---

## 成本估算

### VPS成本（月付）
- **入门**: ¥50-100/月（2核4GB）
- **标准**: ¥150-300/月（4核8GB）
- **高性能**: ¥500-1000/月（8核16GB）

### 存储成本（腾讯云COS/阿里云OSS）
- **标准存储**: ¥0.12-0.15/GB/月
- **低频存储**: ¥0.08/GB/月（适合归档）
- **外网下行流量**: ¥0.50-0.80/GB
- **请求次数**: GET ¥0.01/万次，PUT ¥0.01/千次

### 流量优化建议
- 使用CDN加速（¥0.15-0.25/GB）
- 启用内网传输（VPS与OSS同地域）
- 配置对象生命周期自动删除过期文件

### 总成本估算（中等负载）
- VPS: ¥200/月
- 存储(50GB): ¥7/月
- 流量(100GB): ¥50/月
- **合计**: ¥257/月

相比SaaS服务（如Whisper API ¥0.36/分钟），处理1000分钟音频即可收回成本。

---

## 推荐VPS提供商（中国区）

### 国内VPS
1. **腾讯云**: 与COS集成好，内网免费传输
2. **阿里云**: 与OSS集成好，稳定性高
3. **华为云**: 性价比高，OBS兼容S3

### 海外VPS（适合国际业务）
1. **Vultr**: 亚洲多节点，按小时计费
2. **DigitalOcean**: 简单易用，价格透明
3. **Linode**: 性能稳定，支持多地域

### 选择建议
- 与OSS/COS**同地域**可使用内网，节省流量费
- 选择带宽充足的VPS（至少5Mbps）
- 考虑按需计费，避免资源浪费

---

## 总结

### Docker部署（推荐新手）
```bash
# 5分钟快速部署
mkdir ~/nca-toolkit && cd ~/nca-toolkit
nano docker-compose.yml  # 复制Docker配置
nano .env  # 配置API密钥和存储
docker compose up -d
```

### 源码部署（推荐开发者）
```bash
# 需要2-3小时（主要是编译FFmpeg）
sudo apt-get install -y python3.9 build-essential
# ...编译FFmpeg...
git clone https://github.com/stephengpope/no-code-architects-toolkit.git
pip install -r requirements.txt
sudo systemctl enable nca-toolkit
```

### 存储配置

**腾讯云COS**:
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=<SecretId>
S3_SECRET_KEY=<SecretKey>
S3_BUCKET_NAME=<BucketName-APPID>
S3_REGION=ap-guangzhou
```

**阿里云OSS**:
```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=<AccessKeyId>
S3_SECRET_KEY=<AccessKeySecret>
S3_BUCKET_NAME=<BucketName>
S3_REGION=oss-cn-hangzhou
```

---

## 获取帮助

- **官方文档**: https://github.com/stephengpope/no-code-architects-toolkit
- **社区支持**: [No-Code Architects Community](https://www.skool.com/no-code-architects)
- **问题反馈**: GitHub Issues
- **API测试**: [Postman模板](https://bit.ly/49Gkh61)

---

**祝部署顺利！如有问题，欢迎在社区提问。**
