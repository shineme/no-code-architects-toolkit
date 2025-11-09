# S3_PUBLIC_URL Environment Variable Feature

## Summary

Added a new optional environment variable `S3_PUBLIC_URL` that allows users to specify a different public URL for accessing uploaded files when it differs from the S3 endpoint URL used for uploading.

## Changes Made

### 1. Code Changes

#### `services/s3_toolkit.py`
- Added `public_url` parameter to `upload_to_s3()` function
- Modified URL construction logic to use `public_url` when provided, otherwise falls back to `s3_url`

```python
def upload_to_s3(file_path, s3_url, access_key, secret_key, bucket_name, region, public_url=None):
    # ... upload logic ...
    
    # Use public URL if provided, otherwise fall back to endpoint URL
    base_url = public_url if public_url else s3_url
    file_url = f"{base_url}/{bucket_name}/{encoded_filename}"
    return file_url
```

#### `services/cloud_storage.py`
- Added `self.public_url` to `S3CompatibleProvider` class initialization
- Modified `upload_file()` to pass `public_url` to `upload_to_s3()`

```python
class S3CompatibleProvider(CloudStorageProvider):
    def __init__(self):
        # ... existing code ...
        self.public_url = os.environ.get('S3_PUBLIC_URL', '')
    
    def upload_file(self, file_path: str) -> str:
        return upload_to_s3(file_path, self.endpoint_url, self.access_key, 
                          self.secret_key, self.bucket_name, self.region, self.public_url)
```

### 2. Documentation Updates

#### Updated Files:
- `README.md` - Added S3_PUBLIC_URL to environment variables section
- `CLAUDE.md` - Added S3_PUBLIC_URL to environment variables list
- `docs/cloud-installation/env-examples-cn.md` - Added Chinese documentation with examples
- `docs/cloud-installation/s3-public-url-examples.md` - Comprehensive English examples
- `docs/cloud-installation/s3-public-url-examples-cn.md` - Comprehensive Chinese examples

## Use Cases

### 1. Private Network Upload with Public Access
**Problem**: Upload endpoint is internal/private, but need to return public URLs
**Solution**: Set `S3_ENDPOINT_URL` to internal endpoint, `S3_PUBLIC_URL` to public endpoint

**Example (Tencent Cloud COS)**:
```env
S3_ENDPOINT_URL=https://cos.ap-guangzhou.tencentcos.cn  # Private network
S3_PUBLIC_URL=https://cos.ap-guangzhou.myqcloud.com      # Public network
```

**Benefits**: 
- Saves bandwidth costs (internal upload is free)
- Returns accessible public URLs

### 2. CDN Configuration
**Problem**: Files are stored in S3 but served via CDN
**Solution**: Set `S3_PUBLIC_URL` to CDN domain

**Example**:
```env
S3_ENDPOINT_URL=https://s3.amazonaws.com
S3_PUBLIC_URL=https://cdn.yourdomain.com
```

**Benefits**:
- Faster content delivery
- Better user experience

### 3. Custom Domain
**Problem**: Want to serve files from custom domain
**Solution**: Set `S3_PUBLIC_URL` to custom domain

**Example**:
```env
S3_ENDPOINT_URL=https://s3.amazonaws.com
S3_PUBLIC_URL=https://media.yourdomain.com
```

### 4. MinIO Private Deployment
**Problem**: MinIO internal address differs from external address
**Solution**: Set internal address as endpoint, external as public URL

**Example**:
```env
S3_ENDPOINT_URL=http://minio.internal.local:9000
S3_PUBLIC_URL=https://storage.yourdomain.com
```

## Behavior

### Without S3_PUBLIC_URL
```json
{
  "url": "https://cos.ap-guangzhou.tencentcos.cn/bucket/file.mp4"
}
```

### With S3_PUBLIC_URL
```json
{
  "url": "https://cos.ap-guangzhou.myqcloud.com/bucket/file.mp4"
}
```

## Backward Compatibility

✅ **Fully backward compatible**
- `S3_PUBLIC_URL` is optional
- If not set, behavior is unchanged (uses `S3_ENDPOINT_URL`)
- Existing deployments continue to work without modification

## Testing

### Syntax Validation
```bash
python3 -m py_compile services/s3_toolkit.py services/cloud_storage.py
```
✅ Passed

### Function Signature
- `upload_to_s3(file_path, s3_url, access_key, secret_key, bucket_name, region, public_url=None)`
- `public_url` parameter has default value `None`

## Cost Savings Example

Using private network endpoints for upload:

| Scenario | Monthly Upload | Cost (Tencent Cloud) | Annual Savings |
|----------|---------------|---------------------|----------------|
| Public endpoint | 100GB | ~$7-10 USD | $84-120 USD |
| Private endpoint + S3_PUBLIC_URL | 100GB | $0 | $84-120 USD |

## Migration Guide

### For Existing Users

**No action required**. The feature is optional and backward compatible.

### For New Users Wanting This Feature

1. Identify your S3 upload endpoint and public access URL
2. Add both to your `.env` or environment configuration:
   ```env
   S3_ENDPOINT_URL=<upload_endpoint>
   S3_PUBLIC_URL=<public_access_url>
   ```
3. Restart the application
4. Test by uploading a file and verifying the returned URL

## Implementation Notes

- The `public_url` parameter is passed through the entire upload chain
- Empty string is treated as falsy (no public URL set)
- URL construction happens at the final stage in `upload_to_s3()`
- No validation is performed on the URL format (relies on user input)

## Future Enhancements

Potential improvements for future versions:
- URL validation and sanitization
- Automatic detection of CDN/custom domains
- Per-bucket public URL configuration
- URL template support for complex scenarios

## Related Issues

This feature addresses common deployment scenarios where:
- Internal and external network addresses differ
- CDN is used for content delivery
- Custom domains are configured
- Cost optimization is needed

## Documentation Links

- [S3_PUBLIC_URL Examples (English)](./cloud-installation/s3-public-url-examples.md)
- [S3_PUBLIC_URL 示例（中文）](./cloud-installation/s3-public-url-examples-cn.md)
- [Environment Variables Examples (Chinese)](./cloud-installation/env-examples-cn.md)
