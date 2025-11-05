# VPS部署脚本（中文）

本目录包含VPS一键部署脚本，支持腾讯云COS和阿里云OSS。

## 脚本列表

### 1. deploy-vps-tencent-cos.sh
腾讯云COS一键部署脚本

**功能**:
- 自动安装Docker和Docker Compose
- 交互式配置腾讯云COS存储
- 可选SSL证书自动配置
- 自动生成API密钥
- 性能参数优化建议
- 自动测试部署结果

**使用方法**:

直接运行（推荐）:
```bash
curl -fsSL https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-tencent-cos.sh | bash
```

或下载后运行:
```bash
wget https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-tencent-cos.sh
chmod +x deploy-vps-tencent-cos.sh
./deploy-vps-tencent-cos.sh
```

### 2. deploy-vps-alibaba-oss.sh
阿里云OSS一键部署脚本

**功能**:
- 自动安装Docker和Docker Compose
- 交互式配置阿里云OSS存储
- 可选SSL证书自动配置
- 自动生成API密钥
- 性能参数优化建议
- 自动测试部署结果

**使用方法**:

直接运行（推荐）:
```bash
curl -fsSL https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-alibaba-oss.sh | bash
```

或下载后运行:
```bash
wget https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-alibaba-oss.sh
chmod +x deploy-vps-alibaba-oss.sh
./deploy-vps-alibaba-oss.sh
```

## 前置准备

### VPS要求
- 操作系统: Ubuntu 20.04+ 或 Debian 11+
- 最低配置: 2核CPU, 4GB RAM, 40GB硬盘
- 推荐配置: 4核CPU, 8GB RAM, 80GB硬盘
- 网络: 公网IP，开放80/443端口（如使用SSL）或8080端口

### 云存储准备

#### 腾讯云COS
在运行脚本前，需要准备:
1. 创建COS存储桶（权限设为"公有读私有写"）
2. 获取SecretId和SecretKey（在访问密钥管理中创建）
3. 记录存储桶完整名称（包含-APPID后缀）
4. 确认存储桶所在地域

快捷链接:
- 创建存储桶: https://console.cloud.tencent.com/cos5
- 获取密钥: https://console.cloud.tencent.com/cam/capi

#### 阿里云OSS
在运行脚本前，需要准备:
1. 创建OSS Bucket（权限设为"公共读"）
2. 创建RAM子账号并获取AccessKey（推荐）或使用主账号AccessKey
3. 记录Bucket名称
4. 确认Bucket所在地域

快捷链接:
- 创建Bucket: https://oss.console.aliyun.com/
- 创建AccessKey: https://ram.console.aliyun.com/users

### 域名准备（可选，用于SSL）
如果需要HTTPS访问:
1. 准备一个域名（如: api.yourdomain.com）
2. 将域名A记录解析到VPS的IP地址
3. 确保域名已生效（可用ping测试）

## 脚本执行流程

### 1. 系统检查
- 检测操作系统版本
- 检查Docker安装状态
- 验证系统资源

### 2. 安装依赖
- 安装Docker（如未安装）
- 安装Docker Compose
- 配置Docker用户权限

### 3. 创建项目
- 创建项目目录 `~/nca-toolkit`
- 询问是否使用SSL
- 询问云存储配置
- 询问性能参数

### 4. 生成配置
- 创建 `.env` 环境变量文件
- 创建 `docker-compose.yml` 配置
- 生成随机API密钥

### 5. 启动服务
- 拉取Docker镜像
- 启动容器
- 测试API连接
- 显示部署信息

## 配置说明

### SSL配置
脚本会询问是否配置SSL:
- **选择"是"**: 使用Traefik自动申请Let's Encrypt证书，需要域名
- **选择"否"**: 仅使用HTTP，通过IP:8080访问

### 地域选择
- 建议选择离VPS最近的地域以降低延迟
- 如果VPS和存储在同一地域，可选择使用内网endpoint节省流量费用

### 性能参数
- **Workers数量**: 推荐为CPU核心数×2
- **超时时间**: 默认300秒，处理大文件建议增加到600-900秒
- **队列长度**: 默认10，根据服务器资源调整

## 部署后操作

### 查看服务状态
```bash
cd ~/nca-toolkit
docker compose ps
```

### 查看日志
```bash
docker compose logs -f ncat
```

### 重启服务
```bash
docker compose restart
```

### 停止服务
```bash
docker compose stop
```

### 更新服务
```bash
docker compose pull
docker compose up -d
```

### 修改配置
1. 编辑`.env`文件
2. 重启服务: `docker compose up -d --force-recreate`

## 测试API

### 测试连接
```bash
# HTTP访问
curl -X POST http://YOUR_VPS_IP:8080/v1/toolkit/test \
  -H "X-API-Key: YOUR_API_KEY"

# HTTPS访问（如配置了SSL）
curl -X POST https://your-domain.com/v1/toolkit/test \
  -H "X-API-Key: YOUR_API_KEY"
```

### 测试上传
```bash
curl -X POST http://YOUR_VPS_IP:8080/v1/s3/upload \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "file_url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
  }'
```

## 故障排查

### 脚本执行失败
```bash
# 检查系统日志
sudo journalctl -xe

# 检查Docker状态
sudo systemctl status docker
```

### Docker无法启动
```bash
# 查看容器日志
cd ~/nca-toolkit
docker compose logs ncat

# 检查端口占用
sudo lsof -i :8080
```

### API返回错误
```bash
# 进入容器调试
docker compose exec ncat bash

# 查看环境变量
env | grep -E 'API_KEY|S3_'

# 测试Python
python -c "import whisper; import ffmpeg; print('OK')"
```

### 存储连接失败
常见原因:
1. 密钥配置错误 - 检查.env中的密钥是否正确
2. Bucket权限不足 - 确保Bucket设为公共读
3. 网络连接问题 - 测试能否访问存储endpoint
4. Bucket名称错误 - 腾讯云需要完整名称（含-APPID）

## 安全建议

### 1. 保护API密钥
```bash
# 备份.env文件
cp ~/nca-toolkit/.env ~/nca-toolkit/.env.backup

# 设置文件权限
chmod 600 ~/nca-toolkit/.env
```

### 2. 配置防火墙
```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw enable

# 或只允许特定IP
sudo ufw allow from YOUR_IP to any port 8080
```

### 3. 定期更新
```bash
cd ~/nca-toolkit
docker compose pull
docker compose up -d
```

### 4. 监控资源使用
```bash
# 查看容器资源使用
docker stats ncat

# 查看系统资源
htop
```

## 卸载

### 完全删除
```bash
cd ~/nca-toolkit
docker compose down -v
cd ~
rm -rf ~/nca-toolkit
```

### 仅停止服务（保留数据）
```bash
cd ~/nca-toolkit
docker compose stop
```

## 性能优化

### 增加Swap（内存不足时）
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 使用内网Endpoint
如果VPS和存储在同一地域，编辑`.env`:

腾讯云:
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
```

阿里云:
```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com
```

### 调整Workers数量
编辑`.env`:
```env
GUNICORN_WORKERS=8  # 根据CPU核心数调整
```

## 成本估算

### VPS成本
- 入门配置(2核4GB): ¥50-100/月
- 标准配置(4核8GB): ¥150-300/月
- 高性能(8核16GB): ¥500-1000/月

### 存储成本（每月）
- 标准存储: ¥0.12-0.15/GB
- 流量费用: ¥0.50-0.80/GB（外网）
- 内网流量: 免费（VPS与存储同地域）

### 节省成本建议
1. VPS与存储选择同一地域，使用内网传输
2. 配置对象生命周期，自动删除过期文件
3. 使用CDN加速，降低存储流量费用
4. 选择按需计费的VPS提供商

## 更多资源

### 文档
- [完整VPS部署指南](../docs/cloud-installation/vps-deployment-guide-cn.md)
- [快速开始指南](../docs/cloud-installation/quick-start-cn.md)
- [环境变量配置示例](../docs/cloud-installation/env-examples-cn.md)

### 支持
- 官方仓库: https://github.com/stephengpope/no-code-architects-toolkit
- 社区支持: https://www.skool.com/no-code-architects
- API测试: https://bit.ly/49Gkh61

---

**祝部署顺利！如有问题欢迎在社区提问。**
