# S3_PUBLIC_URL 环境变量功能说明

## 简介

新增了一个可选的环境变量 `S3_PUBLIC_URL`，用于指定文件上传后的公共访问 URL，当它与用于上传的 S3 端点 URL 不同时使用。

## 修改的文件

### 1. 代码修改

#### `services/s3_toolkit.py`
- 为 `upload_to_s3()` 函数添加了 `public_url` 参数（可选，默认为 None）
- 修改了 URL 构建逻辑：优先使用 `public_url`，如果未提供则回退到 `s3_url`

```python
def upload_to_s3(file_path, s3_url, access_key, secret_key, bucket_name, region, public_url=None):
    # ... 上传逻辑 ...
    
    # 使用 public_url（如果提供），否则使用 endpoint URL
    base_url = public_url if public_url else s3_url
    file_url = f"{base_url}/{bucket_name}/{encoded_filename}"
    return file_url
```

#### `services/cloud_storage.py`
- 在 `S3CompatibleProvider` 类初始化时添加了 `self.public_url` 读取
- 修改 `upload_file()` 方法，将 `public_url` 传递给 `upload_to_s3()`

```python
class S3CompatibleProvider(CloudStorageProvider):
    def __init__(self):
        # ... 现有代码 ...
        self.public_url = os.environ.get('S3_PUBLIC_URL', '')
    
    def upload_file(self, file_path: str) -> str:
        return upload_to_s3(file_path, self.endpoint_url, self.access_key, 
                          self.secret_key, self.bucket_name, self.region, self.public_url)
```

### 2. 文档更新

#### 更新的文件：
- `README.md` - 在环境变量部分添加了 S3_PUBLIC_URL 说明
- `CLAUDE.md` - 在环境变量列表中添加了 S3_PUBLIC_URL
- `docs/cloud-installation/env-examples-cn.md` - 添加了中文文档和示例
- `docs/cloud-installation/s3-public-url-examples.md` - 详细的英文示例文档
- `docs/cloud-installation/s3-public-url-examples-cn.md` - 详细的中文示例文档

## 使用场景

### 1. 内网上传 + 公网访问
**问题**：上传端点是内网地址，但需要返回公网可访问的 URL  
**解决方案**：设置 `S3_ENDPOINT_URL` 为内网端点，`S3_PUBLIC_URL` 为公网端点

**示例（腾讯云 COS）**：
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn  # 内网
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com      # 公网
```

**好处**：
- 节省带宽费用（内网上传免费）
- 返回可访问的公网 URL
- 年节省费用可达数百元

### 2. CDN 加速配置
**问题**：文件存储在 S3，但通过 CDN 分发  
**解决方案**：设置 `S3_PUBLIC_URL` 为 CDN 域名

**示例**：
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
```

**好处**：
- 更快的内容分发
- 更好的用户体验
- 降低源站压力

### 3. 自定义域名
**问题**：希望通过自定义域名提供文件访问  
**解决方案**：设置 `S3_PUBLIC_URL` 为自定义域名

**示例**：
```env
S3_ENDPOINT_URL=https://s3.amazonaws.com
S3_PUBLIC_URL=https://media.yourdomain.com
```

### 4. MinIO 私有部署
**问题**：MinIO 内部地址与外部访问地址不同  
**解决方案**：设置内部地址为端点，外部地址为公共 URL

**示例**：
```env
S3_ENDPOINT_URL=http://minio.internal.local:9000
S3_PUBLIC_URL=https://storage.yourdomain.com
```

## 行为对比

### 不使用 S3_PUBLIC_URL
```json
{
  "url": "https://cos.ap-guangzhou.tencentcos.cn/bucket/file.mp4"
}
```
❌ 如果是内网地址，外部无法访问

### 使用 S3_PUBLIC_URL
```json
{
  "url": "https://cos.ap-guangzhou.myqcloud.com/bucket/file.mp4"
}
```
✅ 返回公网可访问的 URL

## 向后兼容性

✅ **完全向后兼容**
- `S3_PUBLIC_URL` 是可选的
- 如果不设置，行为保持不变（使用 `S3_ENDPOINT_URL`）
- 现有部署无需修改即可继续工作

## 费用节省示例

使用内网端点上传：

| 场景 | 月上传量 | 费用（腾讯云） | 年节省 |
|------|---------|--------------|--------|
| 公网端点 | 100GB | ~50元 | 600元 |
| 内网端点 + S3_PUBLIC_URL | 100GB | 0元 | 600元 |

**注意**：
- 仅上传流量免费（同地域内网）
- 下载流量仍按公网计费
- VPS 必须与存储服务在同一地域

## 配置步骤

### 新用户

1. 确定您的 S3 上传端点和公共访问 URL
2. 在 `.env` 文件中添加配置：
   ```env
   S3_ENDPOINT_URL=<上传端点>
   S3_PUBLIC_URL=<公共访问URL>
   ```
3. 重启应用
4. 测试上传文件并验证返回的 URL

### 现有用户

**无需操作**。该功能是可选的，完全向后兼容。

如果想启用此功能，只需添加 `S3_PUBLIC_URL` 环境变量即可。

## 测试验证

### 语法验证
```bash
python3 -m py_compile services/s3_toolkit.py services/cloud_storage.py
```
✅ 通过

### 功能测试
1. 设置环境变量
2. 启动应用
3. 调用任意上传接口（如 `/v1/media/convert`）
4. 检查返回的 URL 是否使用了 S3_PUBLIC_URL
5. 测试返回的 URL 是否可访问

## 实现细节

- `public_url` 参数贯穿整个上传链
- 空字符串被视为未设置（使用默认值）
- URL 构建发生在 `upload_to_s3()` 的最后阶段
- 不对 URL 格式进行验证（依赖用户输入）

## 快速配置示例

### 腾讯云 COS（内网上传）

```env
API_KEY=your_api_key
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com
S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

### 阿里云 OSS（内网上传）

```env
API_KEY=your_api_key
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com
S3_PUBLIC_URL=https://oss-cn-hangzhou.aliyuncs.com
S3_ACCESS_KEY=YOUR_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_ACCESS_KEY_SECRET
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou
```

### 使用 CDN

```env
API_KEY=your_api_key
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

## 常见问题

### Q: 必须设置 S3_PUBLIC_URL 吗？
A: 不必须。这是一个可选功能，如果不设置，系统会使用 S3_ENDPOINT_URL。

### Q: 设置后原有功能会受影响吗？
A: 不会。这是完全向后兼容的新功能。

### Q: 可以用于所有 S3 兼容存储吗？
A: 是的。支持腾讯云 COS、阿里云 OSS、AWS S3、MinIO、DigitalOcean Spaces 等所有 S3 兼容存储。

### Q: 如何验证配置是否生效？
A: 调用任意上传接口，检查返回的 URL 是否使用了 S3_PUBLIC_URL 的值。

### Q: URL 末尾需要加斜杠吗？
A: 不需要。系统会自动处理路径拼接。
- ✅ 正确: `https://cos.ap-guangzhou.myqcloud.com`
- ❌ 错误: `https://cos.ap-guangzhou.myqcloud.com/`

## 相关文档

- [S3_PUBLIC_URL 详细示例（中文）](./cloud-installation/s3-public-url-examples-cn.md)
- [S3_PUBLIC_URL Examples (English)](./cloud-installation/s3-public-url-examples.md)
- [环境变量配置示例](./cloud-installation/env-examples-cn.md)
- [快速开始指南](./cloud-installation/quick-start-cn.md)

## 技术支持

如有问题，请：
1. 查阅详细示例文档
2. 检查环境变量配置
3. 查看应用日志
4. 在 GitHub 提交 Issue
