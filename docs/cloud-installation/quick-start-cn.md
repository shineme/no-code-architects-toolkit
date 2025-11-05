# 快速开始指南 - VPS部署（中文）

## 5分钟Docker快速部署

### 前置要求
- Ubuntu 20.04+ 或 Debian 11+ VPS
- 最低2核4GB内存
- 已有腾讯云COS或阿里云OSS账号

### 第一步：安装Docker

```bash
# 一键安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 验证安装
docker --version
```

### 第二步：创建项目

```bash
# 创建目录
mkdir ~/nca-toolkit && cd ~/nca-toolkit

# 创建docker-compose.yml
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
```

### 第三步：配置环境变量

#### 使用腾讯云COS

```bash
cat > .env << 'EOF'
API_KEY=your_secure_random_key_here

# 腾讯云COS配置
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=your_tencent_secret_id
S3_SECRET_KEY=your_tencent_secret_key
S3_BUCKET_NAME=your-bucket-name-appid
S3_REGION=ap-guangzhou

# 性能配置
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
EOF
```

#### 使用阿里云OSS

```bash
cat > .env << 'EOF'
API_KEY=your_secure_random_key_here

# 阿里云OSS配置
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=your_aliyun_access_key_id
S3_SECRET_KEY=your_aliyun_access_key_secret
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou

# 性能配置
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
EOF
```

### 第四步：启动服务

```bash
# 启动
docker compose up -d

# 查看日志
docker compose logs -f
```

### 第五步：测试API

```bash
# 获取您的VPS IP
curl ifconfig.me

# 测试API（替换IP和API_KEY）
curl -X POST http://YOUR_VPS_IP:8080/v1/toolkit/test \
  -H "X-API-Key: your_secure_random_key_here"
```

成功返回：
```json
{
  "code": 200,
  "message": "success",
  "response": {
    "message": "NCA Toolkit API is working!"
  }
}
```

---

## 常用管理命令

```bash
# 重启服务
docker compose restart

# 查看日志
docker compose logs -f ncat

# 停止服务
docker compose stop

# 更新镜像
docker compose pull && docker compose up -d

# 完全删除
docker compose down -v
```

---

## 腾讯云COS快速配置

### 1. 创建存储桶
- 访问: https://console.cloud.tencent.com/cos5
- 点击"创建存储桶"
- 名称: `nca-toolkit`（示例）
- 地域: 选择离VPS最近的
- 权限: **公有读私有写**

### 2. 获取密钥
- 访问: https://console.cloud.tencent.com/cam/capi
- 创建密钥，记录 SecretId 和 SecretKey

### 3. 地域代码对照表
- 广州: `ap-guangzhou`
- 上海: `ap-shanghai`
- 北京: `ap-beijing`
- 成都: `ap-chengdu`
- 深圳: `ap-shenzhen`
- 香港: `ap-hongkong`

### 4. Endpoint格式
```
https://cos.{地域代码}.myqcloud.com
```

例如：`https://cos.ap-guangzhou.myqcloud.com`

---

## 阿里云OSS快速配置

### 1. 创建Bucket
- 访问: https://oss.console.aliyun.com/
- 点击"创建Bucket"
- 名称: `nca-toolkit`（示例）
- 地域: 选择离VPS最近的
- 读写权限: **公共读**

### 2. 获取AccessKey
- 访问: https://ram.console.aliyun.com/users
- 创建用户，开启"编程访问"
- 授权: `AliyunOSSFullAccess`
- 记录 AccessKey ID 和 Secret

### 3. 地域代码对照表
- 杭州: `oss-cn-hangzhou`
- 上海: `oss-cn-shanghai`
- 青岛: `oss-cn-qingdao`
- 北京: `oss-cn-beijing`
- 深圳: `oss-cn-shenzhen`
- 成都: `oss-cn-chengdu`
- 香港: `oss-cn-hongkong`

### 4. Endpoint格式
```
https://{地域代码}.aliyuncs.com
```

例如：`https://oss-cn-hangzhou.aliyuncs.com`

---

## 配置检查清单

### ✅ VPS准备
- [ ] 安装了Docker
- [ ] 开放了8080端口
- [ ] 至少2核4GB内存

### ✅ 云存储准备
- [ ] 创建了Bucket/存储桶
- [ ] 设置为公共读权限
- [ ] 获取了AccessKey/密钥
- [ ] 配置了CORS（如需要）

### ✅ 环境变量配置
- [ ] API_KEY已设置
- [ ] S3_ENDPOINT_URL正确
- [ ] S3_ACCESS_KEY正确
- [ ] S3_SECRET_KEY正确
- [ ] S3_BUCKET_NAME正确
- [ ] S3_REGION匹配地域

### ✅ 服务检查
- [ ] Docker容器运行中
- [ ] 无错误日志
- [ ] 测试API返回200

---

## 常见问题快速解决

### Q1: 容器启动失败
```bash
# 查看详细日志
docker compose logs ncat

# 常见原因：环境变量配置错误
# 解决：检查.env文件格式和内容
```

### Q2: API返回401
```bash
# 原因：API_KEY不匹配
# 解决：确认请求header中X-API-Key与.env中的API_KEY一致
```

### Q3: 上传文件失败
```bash
# 原因：存储配置错误或权限不足
# 解决方法：
# 1. 检查Bucket权限是否为公共读
# 2. 验证密钥是否正确
# 3. 确认Bucket名称完整（腾讯云需要-APPID后缀）
```

### Q4: 端口无法访问
```bash
# 检查防火墙
sudo ufw allow 8080/tcp

# 检查端口监听
sudo netstat -tlnp | grep 8080

# 检查云服务商安全组
# 需要在控制台开放8080端口
```

### Q5: 内存不足
```bash
# 添加swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 性能优化建议

### 根据CPU核心数调整Workers

```env
# 2核CPU
GUNICORN_WORKERS=4

# 4核CPU
GUNICORN_WORKERS=8

# 8核CPU
GUNICORN_WORKERS=16
```

公式：`Workers = CPU核心数 × 2`

### 处理大文件增加超时

```env
# 默认5分钟
GUNICORN_TIMEOUT=300

# 处理大视频增加到15分钟
GUNICORN_TIMEOUT=900
```

### 使用内网Endpoint节省流量

**腾讯云COS内网**（VPS和COS同地域）:
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
```

**阿里云OSS内网**（VPS和OSS同地域）:
```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com
```

---

## 进阶配置

### 添加SSL证书（使用域名访问）

修改`docker-compose.yml`使用Traefik：

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
    restart: unless-stopped

volumes:
  traefik_data:
    driver: local
  storage:
    driver: local
```

在`.env`中添加：
```env
APP_DOMAIN=api.yourdomain.com
SSL_EMAIL=your@email.com
```

重启服务：
```bash
docker compose up -d
```

---

## 监控和维护

### 查看资源使用

```bash
# 实时监控
docker stats ncat

# 查看磁盘使用
df -h

# 查看内存使用
free -h
```

### 定期清理

```bash
# 清理Docker缓存
docker system prune -f

# 清理旧日志
sudo find /var/log -type f -name "*.log" -mtime +7 -delete
```

### 自动备份配置

```bash
# 创建备份脚本
cat > ~/backup-nca.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/nca-backups
mkdir -p $BACKUP_DIR
cd ~/nca-toolkit
tar czf $BACKUP_DIR/nca-backup-$(date +%Y%m%d).tar.gz .env docker-compose.yml
# 保留最近7天的备份
find $BACKUP_DIR -name "nca-backup-*.tar.gz" -mtime +7 -delete
EOF

chmod +x ~/backup-nca.sh

# 添加到crontab（每天凌晨2点备份）
(crontab -l 2>/dev/null; echo "0 2 * * * ~/backup-nca.sh") | crontab -
```

---

## 下一步

### 测试API功能
使用Postman测试集：https://bit.ly/49Gkh61

### 集成到您的应用
参考API文档：
- 音频转录：`/v1/media/transcribe`
- 视频处理：`/v1/video/caption`
- 媒体转换：`/v1/media/convert`

### 加入社区
获取支持和最新更新：https://www.skool.com/no-code-architects

---

## 完整文档

详细部署指南请参考：[VPS部署完整指南](./vps-deployment-guide-cn.md)

---

**部署完成！开始使用您自己的媒体处理API吧！** 🚀
