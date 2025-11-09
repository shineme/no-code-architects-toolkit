# S3_PUBLIC_URL Configuration Examples

## Overview

The `S3_PUBLIC_URL` environment variable allows you to specify a different public URL for accessing uploaded files when it differs from the S3 endpoint URL used for uploading.

## Common Use Cases

### 1. Private Network Upload with Public Access

When your application server is in the same region as your S3 storage, you can use internal/private endpoints for upload (saving bandwidth costs) while returning public URLs for file access.

#### Tencent Cloud COS Example

```env
# Upload via private network (free bandwidth)
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn

# Return public URLs for file access
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com

S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

#### Alibaba Cloud OSS Example

```env
# Upload via internal network (free bandwidth)
S3_ENDPOINT_URL=https://oss-cn-hangzhou-internal.aliyuncs.com

# Return public URLs for file access
S3_PUBLIC_URL=https://oss-cn-hangzhou.aliyuncs.com

S3_ACCESS_KEY=YOUR_ACCESS_KEY_ID
S3_SECRET_KEY=YOUR_ACCESS_KEY_SECRET
S3_BUCKET_NAME=your-bucket-name
S3_REGION=oss-cn-hangzhou
```

### 2. CDN Configuration

When using a CDN in front of your S3 storage, set the CDN URL as the public URL.

#### With CloudFlare CDN

```env
# Upload to origin S3
S3_ENDPOINT_URL=https://s3.us-west-2.amazonaws.com

# Return CDN URLs
S3_PUBLIC_URL=https://cdn.yourdomain.com

S3_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
S3_SECRET_KEY=YOUR_AWS_SECRET_KEY
S3_BUCKET_NAME=your-bucket
S3_REGION=us-west-2
```

#### With Tencent Cloud CDN

```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.myqcloud.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
S3_ACCESS_KEY=YOUR_SECRET_ID
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET_NAME=your-bucket-1234567890
S3_REGION=ap-guangzhou
```

### 3. Custom Domain

When you've configured a custom domain for your S3 bucket.

```env
# Upload to S3 endpoint
S3_ENDPOINT_URL=https://s3.eu-central-1.amazonaws.com

# Return custom domain URLs
S3_PUBLIC_URL=https://media.yourdomain.com

S3_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
S3_SECRET_KEY=YOUR_AWS_SECRET_KEY
S3_BUCKET_NAME=your-bucket
S3_REGION=eu-central-1
```

### 4. MinIO with Different Internal/External Addresses

```env
# Internal MinIO endpoint (not accessible from outside)
S3_ENDPOINT_URL=http://minio.internal.local:9000

# Public-facing URL
S3_PUBLIC_URL=https://storage.yourdomain.com

S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=uploads
S3_REGION=us-east-1
```

## How It Works

1. **Without S3_PUBLIC_URL**: The API returns URLs like:
   ```
   {S3_ENDPOINT_URL}/{S3_BUCKET_NAME}/{filename}
   ```

2. **With S3_PUBLIC_URL**: The API returns URLs like:
   ```
   {S3_PUBLIC_URL}/{S3_BUCKET_NAME}/{filename}
   ```

## Example Response

### Without S3_PUBLIC_URL

```json
{
  "code": 200,
  "response": {
    "url": "https://cos.ap-guangzhou.tencentcos.cn/my-bucket/video.mp4"
  }
}
```

### With S3_PUBLIC_URL

```json
{
  "code": 200,
  "response": {
    "url": "https://cos.ap-guangzhou.myqcloud.com/my-bucket/video.mp4"
  }
}
```

## Cost Savings Example

Using private network endpoints for upload can significantly reduce costs:

| Scenario | Upload Traffic | Cost (Tencent Cloud) |
|----------|---------------|---------------------|
| Public endpoint | 100GB | ~$7-10 USD |
| Private endpoint + S3_PUBLIC_URL | 100GB | $0 (free) |

## Important Notes

1. **Optional Variable**: If `S3_PUBLIC_URL` is not set, the system defaults to using `S3_ENDPOINT_URL`.

2. **No Trailing Slash**: Do not include a trailing slash in the URL:
   - ✅ Correct: `https://cos.ap-guangzhou.myqcloud.com`
   - ❌ Wrong: `https://cos.ap-guangzhou.myqcloud.com/`

3. **Protocol**: Use `https://` for production environments.

4. **Region Compatibility**: Ensure your server can access the internal endpoint when using private network configuration.

5. **Testing**: After configuration, test file access by calling any endpoint that uploads files (e.g., `/v1/media/convert`) and verify the returned URL is accessible.

## Troubleshooting

### Issue: Returned URLs are not accessible

**Solution**: Check that:
- S3_PUBLIC_URL is correctly formatted
- The bucket has public read permissions
- CDN/custom domain is properly configured

### Issue: Still seeing internal URLs in responses

**Solution**: 
- Verify S3_PUBLIC_URL is set in your environment
- Restart the application after changing environment variables
- Check logs for any configuration errors

## Related Documentation

- [Environment Variables Configuration (Chinese)](./env-examples-cn.md)
- [Quick Start Guide (Chinese)](./quick-start-cn.md)
- [VPS Deployment Guide (Chinese)](./vps-deployment-guide-cn.md)
