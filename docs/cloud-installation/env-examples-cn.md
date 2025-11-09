# 环境变量配置示例（中文）

本文档提供各种场景下的`.env`配置示例，方便直接复制使用。

---

## 目录
1. [腾讯云COS配置](#腾讯云cos配置)
2. [阿里云OSS配置](#阿里云oss配置)
3. [GCP存储配置](#gcp存储配置)
4. [完整配置示例](#完整配置示例)
5. [Docker Compose配置](#docker-compose配置)

---

## 腾讯云COS配置

### 基础配置（公网访问）

```env
# ============================================
# 腾讯云COS - 基础配置
# ============================================

# API密钥（必填）
API_KEY=your_secure_random_api_key

# 腾讯云COS配置
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID_HERE
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=your-bucket-name-1234567890
S3_REGION=ap-guangzhou

# 性能配置（可选）
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
LOCAL_STORAGE_PATH=/tmp
```

### 内网访问配置（节省流量费用）

```env
# ============================================
# 腾讯云COS - 内网配置
# 注意：VPS必须与COS在同一地域
# ============================================

API_KEY=your_secure_random_api_key

# 使用内网endpoint上传，公网URL访问
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID_HERE
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=your-bucket-name-1234567890
S3_REGION=ap-guangzhou

GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
```

**说明**: 通过内网endpoint上传可以节省流量费用，同时通过S3_PUBLIC_URL设置公网访问地址，确保返回的文件URL可以被外部访问。

### 腾讯云COS地域列表

| 地域 | 公网Endpoint | 内网Endpoint | Region代码 |
|------|-------------|--------------|-----------|
| 北京 | `https://cos.ap-beijing.myqcloud.com` | `https://cos.ap-beijing.tencentcos.cn` | `ap-beijing` |
| 上海 | `https://cos.ap-shanghai.myqcloud.com` | `https://cos.ap-shanghai.tencentcos.cn` | `ap-shanghai` |
| 广州 | `https://cos.ap-guangzhou.myqcloud.com` | `https://cos.ap-guangzhou.tencentcos.cn` | `ap-guangzhou` |
| 成都 | `https://cos.ap-chengdu.myqcloud.com` | `https://cos.ap-chengdu.tencentcos.cn` | `ap-chengdu` |
| 重庆 | `https://cos.ap-chongqing.myqcloud.com` | `https://cos.ap-chongqing.tencentcos.cn` | `ap-chongqing` |
| 深圳 | `https://cos.ap-shenzhen.myqcloud.com` | `https://cos.ap-shenzhen.tencentcos.cn` | `ap-shenzhen` |
| 香港 | `https://cos.ap-hongkong.myqcloud.com` | `https://cos.ap-hongkong.tencentcos.cn` | `ap-hongkong` |
| 新加坡 | `https://cos.ap-singapore.myqcloud.com` | `https://cos.ap-singapore.tencentcos.cn` | `ap-singapore` |
| 东京 | `https://cos.ap-tokyo.myqcloud.com` | `https://cos.ap-tokyo.tencentcos.cn` | `ap-tokyo` |
| 首尔 | `https://cos.ap-seoul.myqcloud.com` | `https://cos.ap-seoul.tencentcos.cn` | `ap-seoul` |

更多地域：https://cloud.tencent.com/document/product/436/6224

---

## 阿里云OSS配置

### 基础配置（公网访问）

```env
# ============================================
# 阿里云OSS - 基础配置
# ============================================

# API密钥（必填）
API_KEY=your_secure_random_api_key

# 阿里云OSS配置
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=YOUR_ALIYUN_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou

# 性能配置（可选）
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
LOCAL_STORAGE_PATH=/tmp
```

### 内网访问配置（节省流量费用）

```env
# ============================================
# 阿里云OSS - 内网配置
# 注意：VPS必须与OSS在同一地域
# ============================================

API_KEY=your_secure_random_api_key

# 使用内网endpoint上传，公网URL访问
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com
S3_PUBLIC_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=YOUR_ALIYUN_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou

GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
```

**说明**: 通过内网endpoint上传可以节省流量费用，同时通过S3_PUBLIC_URL设置公网访问地址，确保返回的文件URL可以被外部访问。

### 阿里云OSS地域列表

| 地域 | 公网Endpoint | 内网Endpoint | Region代码 |
|------|-------------|--------------|-----------|
| 华东1(杭州) | `https://oss-cn-hangzhou.aliyuncs.com` | `https://oss-cn-hangzhou-internal.aliyuncs.com` | `oss-cn-hangzhou` |
| 华东2(上海) | `https://oss-cn-shanghai.aliyuncs.com` | `https://oss-cn-shanghai-internal.aliyuncs.com` | `oss-cn-shanghai` |
| 华北1(青岛) | `https://oss-cn-qingdao.aliyuncs.com` | `https://oss-cn-qingdao-internal.aliyuncs.com` | `oss-cn-qingdao` |
| 华北2(北京) | `https://oss-cn-beijing.aliyuncs.com` | `https://oss-cn-beijing-internal.aliyuncs.com` | `oss-cn-beijing` |
| 华北3(张家口) | `https://oss-cn-zhangjiakou.aliyuncs.com` | `https://oss-cn-zhangjiakou-internal.aliyuncs.com` | `oss-cn-zhangjiakou` |
| 华南1(深圳) | `https://oss-cn-shenzhen.aliyuncs.com` | `https://oss-cn-shenzhen-internal.aliyuncs.com` | `oss-cn-shenzhen` |
| 西南1(成都) | `https://oss-cn-chengdu.aliyuncs.com` | `https://oss-cn-chengdu-internal.aliyuncs.com` | `oss-cn-chengdu` |
| 中国(香港) | `https://oss-cn-hongkong.aliyuncs.com` | `https://oss-cn-hongkong-internal.aliyuncs.com` | `oss-cn-hongkong` |
| 新加坡 | `https://oss-ap-southeast-1.aliyuncs.com` | `https://oss-ap-southeast-1-internal.aliyuncs.com` | `oss-ap-southeast-1` |
| 日本(东京) | `https://oss-ap-northeast-1.aliyuncs.com` | `https://oss-ap-northeast-1-internal.aliyuncs.com` | `oss-ap-northeast-1` |

更多地域：https://help.aliyun.com/document_detail/31837.html

---

## GCP存储配置

### Google Cloud Storage

```env
# ============================================
# Google Cloud Storage (GCS)
# ============================================

API_KEY=your_secure_random_api_key

# GCP配置
GCP_SA_CREDENTIALS={"type":"service_account","project_id":"your-project","private_key_id":"xxx","private_key":"-----BEGIN PRIVATE KEY-----\nxxx\n-----END PRIVATE KEY-----\n","client_email":"xxx@xxx.iam.gserviceaccount.com","client_id":"xxx","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"xxx"}
GCP_BUCKET_NAME=your-gcs-bucket-name

GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
```

**注意**: `GCP_SA_CREDENTIALS` 应该是单行JSON字符串，不能换行。

---

## 完整配置示例

### 生产环境 - 腾讯云COS + SSL

```env
# ============================================
# 生产环境配置 - 腾讯云COS + SSL
# ============================================

# 应用配置
APP_NAME=NCAToolkit
APP_DEBUG=false

# 域名配置（使用Traefik自动SSL）
APP_DOMAIN=api.yourdomain.com
APP_URL=https://${APP_DOMAIN}
SSL_EMAIL=admin@yourdomain.com

# API认证
API_KEY=use_a_strong_random_key_here_min_32_chars

# 腾讯云COS存储
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID_HERE
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=production-media-1234567890
S3_REGION=ap-guangzhou

# 性能优化（4核8GB服务器）
GUNICORN_WORKERS=8
GUNICORN_THREADS=2
GUNICORN_TIMEOUT=600
MAX_QUEUE_LENGTH=20
LOCAL_STORAGE_PATH=/tmp

# 日志配置
LOG_LEVEL=INFO
```

### 开发环境 - 阿里云OSS + HTTP

```env
# ============================================
# 开发环境配置 - 阿里云OSS + HTTP
# ============================================

# 应用配置
APP_NAME=NCAToolkit-Dev
APP_DEBUG=true

# API认证
API_KEY=dev_api_key_for_testing

# 阿里云OSS存储
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=YOUR_ALIYUN_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=dev-media-bucket
S3_REGION=oss-cn-hangzhou

# 性能配置（2核4GB开发服务器）
GUNICORN_WORKERS=2
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=5
LOCAL_STORAGE_PATH=/tmp

# 日志配置
LOG_LEVEL=DEBUG
```

### 高性能配置 - 8核16GB服务器

```env
# ============================================
# 高性能配置 - 8核16GB服务器
# ============================================

API_KEY=high_performance_api_key

# 腾讯云COS（内网）
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID_HERE
S3_SECRET_KEY=YOUR_SECRET_KEY_HERE
S3_BUCKET_NAME=hp-media-1234567890
S3_REGION=ap-guangzhou

# 高性能配置
GUNICORN_WORKERS=16
GUNICORN_THREADS=4
GUNICORN_TIMEOUT=900
GUNICORN_WORKER_CLASS=sync
GUNICORN_KEEPALIVE=120
MAX_QUEUE_LENGTH=50
LOCAL_STORAGE_PATH=/data/nca-tmp

# Whisper缓存
WHISPER_CACHE_DIR=/data/whisper-cache
```

### 最小配置 - 入门测试

```env
# ============================================
# 最小配置 - 入门测试
# ============================================

API_KEY=test123456

# 选择一个存储服务

# 腾讯云COS
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=your_secret_id
S3_SECRET_KEY=your_secret_key
S3_BUCKET_NAME=your-bucket-name-appid
S3_REGION=ap-guangzhou

# 或阿里云OSS（注释掉上面的腾讯云配置）
#S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
#S3_ACCESS_KEY=your_access_key_id
#S3_SECRET_KEY=your_access_key_secret
#S3_BUCKET_NAME=your-bucket-name
#S3_REGION=oss-cn-hangzhou
```

---

## Docker Compose配置

### 方案1: 简单HTTP部署

```yaml
# docker-compose.yml
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

### 方案2: 使用Traefik自动SSL

```yaml
# docker-compose.yml
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
```

配套`.env`:
```env
APP_DOMAIN=api.yourdomain.com
SSL_EMAIL=your@email.com
API_KEY=your_api_key
# ... 其他配置
```

### 方案3: 自定义存储路径

```yaml
# docker-compose.yml
services:
  ncat:
    image: stephengpope/no-code-architects-toolkit:latest
    ports:
      - "8080:8080"
    env_file:
      - .env
    volumes:
      # 使用宿主机目录
      - /data/nca-storage:/tmp
      - /data/nca-logs:/app/logs
      - /data/whisper-cache:/app/whisper_cache
    restart: unless-stopped
```

创建目录：
```bash
sudo mkdir -p /data/nca-storage /data/nca-logs /data/whisper-cache
sudo chmod -R 777 /data/nca-storage /data/nca-logs /data/whisper-cache
```

### 方案4: 多容器负载均衡

```yaml
# docker-compose.yml
services:
  traefik:
    image: "traefik:latest"
    restart: unless-stopped
    command:
      - "--api=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
  
  ncat1:
    image: stephengpope/no-code-architects-toolkit:latest
    env_file:
      - .env
    labels:
      - traefik.enable=true
      - traefik.http.routers.ncat.rule=Host(`${APP_DOMAIN}`)
      - traefik.http.services.ncat.loadbalancer.server.port=8080
    volumes:
      - storage1:/tmp
    restart: unless-stopped
  
  ncat2:
    image: stephengpope/no-code-architects-toolkit:latest
    env_file:
      - .env
    labels:
      - traefik.enable=true
      - traefik.http.routers.ncat.rule=Host(`${APP_DOMAIN}`)
      - traefik.http.services.ncat.loadbalancer.server.port=8080
    volumes:
      - storage2:/tmp
    restart: unless-stopped

volumes:
  storage1:
    driver: local
  storage2:
    driver: local
```

---

## 环境变量完整参考

### 必填变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `API_KEY` | API认证密钥 | `your_secure_api_key` |

### 存储配置（二选一）

#### 选项1: S3兼容存储（腾讯云/阿里云/其他）

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `S3_ENDPOINT_URL` | S3端点URL | `https://cos.ap-guangzhou.myqcloud.com` |
| `S3_ACCESS_KEY` | 访问密钥ID | `AKIDxxx...` 或 `LTAI5txxx...` |
| `S3_SECRET_KEY` | 访问密钥Secret | `xxx...` |
| `S3_BUCKET_NAME` | 存储桶名称 | `bucket-name-appid` |
| `S3_REGION` | 地域 | `ap-guangzhou` 或 `oss-cn-hangzhou` |
| `S3_PUBLIC_URL` | 公共访问URL（可选） | `https://cdn.example.com` |

**注意**: `S3_PUBLIC_URL` 用于指定文件的公共访问URL基础路径。当公共访问URL与S3_ENDPOINT_URL不同时使用（例如使用CDN、自定义域名或内网上传时）。如不设置则默认使用 S3_ENDPOINT_URL。

#### 选项2: Google Cloud Storage

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `GCP_SA_CREDENTIALS` | 服务账号JSON | `{"type":"service_account",...}` |
| `GCP_BUCKET_NAME` | GCS存储桶名称 | `your-gcs-bucket` |

### 性能调优（可选）

| 变量名 | 说明 | 默认值 | 推荐值 |
|--------|------|--------|--------|
| `GUNICORN_WORKERS` | Worker进程数 | CPU核心数+1 | CPU核心数×2 |
| `GUNICORN_TIMEOUT` | 请求超时(秒) | 300 | 300-900 |
| `MAX_QUEUE_LENGTH` | 最大队列长度 | 0(无限) | 10-50 |
| `LOCAL_STORAGE_PATH` | 临时存储路径 | `/tmp` | `/tmp` 或 `/data/tmp` |

### 应用配置（可选）

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `APP_NAME` | 应用名称 | `NCAToolkit` |
| `APP_DEBUG` | 调试模式 | `false` |
| `APP_DOMAIN` | 应用域名 | - |
| `SSL_EMAIL` | SSL证书邮箱 | - |
| `WHISPER_CACHE_DIR` | Whisper模型缓存 | `/app/whisper_cache` |

---

## 快速启动命令

### 创建配置文件

```bash
# 进入项目目录
cd ~/nca-toolkit

# 创建.env（使用腾讯云COS）
cat > .env << 'EOF'
API_KEY=your_random_secure_key
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=your_tencent_secret_id
S3_SECRET_KEY=your_tencent_secret_key
S3_BUCKET_NAME=your-bucket-name-appid
S3_REGION=ap-guangzhou
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
EOF

# 创建docker-compose.yml（简单版）
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
    restart: unless-stopped
volumes:
  storage:
    driver: local
EOF

# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f
```

### 验证配置

```bash
# 测试API
curl -X POST http://localhost:8080/v1/toolkit/test \
  -H "X-API-Key: your_random_secure_key"

# 应返回:
# {"code":200,"message":"success","response":{"message":"NCA Toolkit API is working!"}}
```

---

## 配置建议

### 安全性
- ✅ 使用强随机API密钥（至少32字符）
- ✅ 不要在公开仓库提交`.env`文件
- ✅ 定期轮换访问密钥
- ✅ 使用RAM子账号而非主账号密钥

### 性能
- ✅ 根据CPU核心数调整Workers
- ✅ VPS与存储同地域使用内网endpoint
- ✅ 增加大文件处理的超时时间
- ✅ 预留足够的临时存储空间

### 成本
- ✅ 使用内网传输节省流量费
- ✅ 配置对象生命周期自动删除
- ✅ 选择合适的存储类型（标准/低频）
- ✅ 启用CDN降低OSS外网流量

---

## 故障排查

### 检查配置是否加载

```bash
# Docker部署
docker compose exec ncat env | grep -E 'API_KEY|S3_|GCP_'

# 源码部署
source venv/bin/activate
python -c "import os; print(os.getenv('API_KEY')); print(os.getenv('S3_ENDPOINT_URL'))"
```

### 验证存储连接

```bash
# 测试上传功能
curl -X POST http://localhost:8080/v1/s3/upload \
  -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "file_url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
  }'
```

---

**提示**: 复制配置时，请替换所有`your_xxx`占位符为实际值！
