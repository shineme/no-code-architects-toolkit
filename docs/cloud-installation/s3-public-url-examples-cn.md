# S3_PUBLIC_URL 配置示例

## 概述

`S3_PUBLIC_URL` 环境变量允许您为上传的文件指定一个与 S3 上传端点不同的公共访问 URL。

## 常见使用场景

### 1. 内网上传 + 公网访问

当您的应用服务器与 S3 存储在同一地域时，可以使用内网端点上传（节省带宽费用），同时返回公网 URL 供外部访问。

#### 腾讯云 COS 示例

```env
# 通过内网上传（免带宽费）
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn

# 返回公网 URL 供访问
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com

S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

**费用对比**:
- 使用公网端点上传 100GB: 约 50-70 元人民币
- 使用内网端点上传 100GB: 免费

#### 阿里云 OSS 示例

```env
# 通过内网上传（免流量费）
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com

# 返回公网 URL 供访问
S3_PUBLIC_URL=https://oss-cn-hangzhou.aliyuncs.com

S3_ACCESS_KEY=YOUR_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_ACCESS_KEY_SECRET
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou
```

### 2. CDN 加速配置

当您在 S3 存储前配置了 CDN 时，将 CDN 地址设置为公网 URL。

#### 使用腾讯云 CDN

```env
# 上传到 COS
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com

# 返回 CDN 加速域名
S3_PUBLIC_URL=https://cdn.yourdomain.com

S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

#### 使用阿里云 CDN

```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
S3_ACCESS_KEY=YOUR_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_ACCESS_KEY_SECRET
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou
```

#### 使用 CloudFlare CDN

```env
S3_ENDPOINT_URL=https://s3.us-west-2.amazonaws.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
S3_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
S3_SECRET_KEY=YOUR_AWS_SECRET_KEY
S3_BUCKET_NAME=your-bucket
S3_REGION=us-west-2
```

### 3. 自定义域名

当您为 S3 存储桶配置了自定义域名时。

#### 腾讯云 COS 自定义域名

```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_PUBLIC_URL=https://media.yourdomain.com
S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

#### 阿里云 OSS 自定义域名

```env
S3_ENDPOINT_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_PUBLIC_URL=https://static.yourdomain.com
S3_ACCESS_KEY=YOUR_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_ACCESS_KEY_SECRET
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou
```

### 4. MinIO 私有部署

当 MinIO 的内部地址和外部访问地址不同时。

```env
# MinIO 内部端点（外部无法访问）
S3_ENDPOINT_URL=http://minio.internal.local:9000

# 公网访问地址
S3_PUBLIC_URL=https://storage.yourdomain.com

S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=uploads
S3_REGION=us-east-1
```

## 工作原理

1. **不设置 S3_PUBLIC_URL**: API 返回的 URL 格式为：
   ```
   {S3_ENDPOINT_URL}/{S3_BUCKET_NAME}/{filename}
   ```

2. **设置 S3_PUBLIC_URL**: API 返回的 URL 格式为：
   ```
   {S3_PUBLIC_URL}/{S3_BUCKET_NAME}/{filename}
   ```

## 响应示例对比

### 不使用 S3_PUBLIC_URL

```json
{
  "code": 200,
  "response": {
    "url": "https://cos.ap-guangzhou.tencentcos.cn/my-bucket/video.mp4"
  }
}
```

❌ 问题：如果使用内网端点，这个 URL 外部无法访问

### 使用 S3_PUBLIC_URL

```json
{
  "code": 200,
  "response": {
    "url": "https://cos.ap-guangzhou.myqcloud.com/my-bucket/video.mp4"
  }
}
```

✅ 正确：返回的是公网可访问的 URL

## 费用节省示例

使用内网端点上传可以显著降低成本：

| 场景 | 上传流量 | 费用（腾讯云） | 年费用（每天1GB） |
|------|---------|---------------|------------------|
| 公网端点 | 100GB/月 | ~50元 | ~600元 |
| 内网端点 + S3_PUBLIC_URL | 100GB/月 | 免费 | 免费 |

**说明**: 
- 腾讯云/阿里云同地域内网上传免流量费
- 下载流量按公网计费（用户访问时产生）
- VPS 必须与存储服务在同一地域

## 完整配置示例

### Docker Compose 配置

```yaml
# docker-compose.yml
services:
  ncat:
    image: stephengpope/no-code-architects-toolkit:latest
    ports:
      - "8080:8080"
    environment:
      # API 密钥
      - API_KEY=your_secure_api_key
      
      # 内网上传，公网访问
      - S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
      - S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com
      - S3_ACCESS_KEY=YOUR_SECRET_ID
      - S3_SECRET_KEY=YOUR_SECRET_KEY
      - S3_BUCKET_NAME=your-bucket-1234567890
      - S3_REGION=ap-guangzhou
      
      # 性能配置
      - GUNICORN_WORKERS=4
      - GUNICORN_TIMEOUT=300
    volumes:
      - storage:/tmp
    restart: unless-stopped

volumes:
  storage:
    driver: local
```

### 环境变量文件 (.env)

```env
# ============================================
# 生产环境配置 - 内网上传 + 公网访问
# ============================================

# API 认证
API_KEY=your_secure_random_api_key_here

# 腾讯云 COS（内网上传）
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_TENCENT_SECRET_ID
S3_SECRET_KEY=YOUR_TENCENT_SECRET_KEY
S3_BUCKET_NAME=production-media-1234567890
S3_REGION=ap-guangzhou

# 性能优化
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=300
MAX_QUEUE_LENGTH=10
```

## 各云服务商配置对照表

| 云服务商 | 内网 Endpoint | 公网 URL | 备注 |
|---------|--------------|---------|------|
| 腾讯云-北京 | `cos.ap-beijing.tencentcos.cn` | `cos.ap-beijing.myqcloud.com` | 内网上传免费 |
| 腾讯云-上海 | `cos.ap-shanghai.tencentcos.cn` | `cos.ap-shanghai.myqcloud.com` | 内网上传免费 |
| 腾讯云-广州 | `cos.ap-guangzhou.tencentcos.cn` | `cos.ap-guangzhou.myqcloud.com` | 内网上传免费 |
| 阿里云-杭州 | `oss-cn-hangzhou-internal.aliyuncs.com` | `oss-cn-hangzhou.aliyuncs.com` | 内网流量免费 |
| 阿里云-北京 | `oss-cn-beijing-internal.aliyuncs.com` | `oss-cn-beijing.aliyuncs.com` | 内网流量免费 |
| 阿里云-上海 | `oss-cn-shanghai-internal.aliyuncs.com` | `oss-cn-shanghai.aliyuncs.com` | 内网流量免费 |

## 重要提示

1. **可选变量**: 如果不设置 `S3_PUBLIC_URL`，系统默认使用 `S3_ENDPOINT_URL`。

2. **不要添加尾部斜杠**: URL 末尾不要包含斜杠：
   - ✅ 正确: `https://cos.ap-guangzhou.myqcloud.com`
   - ❌ 错误: `https://cos.ap-guangzhou.myqcloud.com/`

3. **协议**: 生产环境建议使用 `https://`。

4. **地域兼容性**: 
   - 使用内网配置时，VPS 必须与存储服务在同一地域
   - 腾讯云：VPS 在广州地域才能使用广州 COS 的内网端点
   - 阿里云：VPS 在杭州地域才能使用杭州 OSS 的内网端点

5. **存储桶权限**: 确保存储桶设置了公共读权限，否则返回的 URL 无法访问。

6. **测试**: 配置后通过调用上传端点（如 `/v1/media/convert`）并验证返回的 URL 可访问。

## 测试方法

### 1. 启动服务

```bash
docker compose up -d
```

### 2. 测试上传

```bash
curl -X POST http://localhost:8080/v1/media/convert \
  -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "media_url": "https://example.com/sample.mp4",
    "output_format": "mp3"
  }'
```

### 3. 检查返回的 URL

响应中的 `url` 字段应该使用 `S3_PUBLIC_URL` 的值：

```json
{
  "code": 200,
  "response": {
    "url": "https://cos.ap-guangzhou.myqcloud.com/bucket/output.mp3"
  }
}
```

### 4. 验证 URL 可访问

```bash
curl -I https://cos.ap-guangzhou.myqcloud.com/bucket/output.mp3
```

应该返回 `200 OK`。

## 故障排查

### 问题：返回的 URL 无法访问

**可能原因**:
- S3_PUBLIC_URL 格式错误
- 存储桶未设置公共读权限
- CDN/自定义域名未正确配置

**解决方案**:
1. 检查 S3_PUBLIC_URL 是否正确
2. 登录云控制台，设置存储桶为公共读
3. 如使用 CDN，确保 CDN 已正确绑定并生效

### 问题：响应中仍然显示内网 URL

**可能原因**:
- S3_PUBLIC_URL 未正确设置
- 容器未重启导致环境变量未生效

**解决方案**:
```bash
# 检查环境变量
docker compose exec ncat env | grep S3

# 重启容器
docker compose restart

# 查看日志
docker compose logs -f
```

### 问题：内网端点无法连接

**可能原因**:
- VPS 与存储服务不在同一地域
- 内网端点 URL 错误

**解决方案**:
1. 确认 VPS 所在地域
2. 使用对应地域的内网端点
3. 或改用公网端点（但会产生流量费）

## 最佳实践

### 1. 生产环境推荐配置

```env
# 使用内网上传 + CDN 加速访问
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_PUBLIC_URL=https://cdn.yourdomain.com
```

**优势**:
- 上传免流量费
- CDN 加速访问
- 降低存储服务器压力

### 2. 测试环境推荐配置

```env
# 简单配置，不设置 PUBLIC_URL
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
# S3_PUBLIC_URL 留空，自动使用 ENDPOINT_URL
```

### 3. 高流量网站推荐配置

```env
# 内网上传 + CDN + 多地域加速
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_PUBLIC_URL=https://global-cdn.yourdomain.com
```

## 相关文档

- [环境变量配置示例](./env-examples-cn.md)
- [快速开始指南](./quick-start-cn.md)
- [VPS 部署指南](./vps-deployment-guide-cn.md)
- [S3_PUBLIC_URL Examples (English)](./s3-public-url-examples.md)
