# VPS部署指南索引（中文）

欢迎使用No-Code Architects Toolkit VPS部署指南！本文档帮助您在自己的VPS上快速部署项目。

## 🚀 快速开始（推荐新手）

**如果您是第一次部署，建议按以下顺序阅读：**

1. **[5分钟快速开始指南](./quick-start-cn.md)** ⭐ 推荐
   - 最快的部署方式
   - 使用Docker一键部署
   - 适合快速测试和入门

2. **[环境变量配置示例](./env-examples-cn.md)**
   - 复制粘贴即可使用的配置模板
   - 腾讯云COS和阿里云OSS配置对照表
   - 各种场景的配置示例

3. **[完整VPS部署指南](./vps-deployment-guide-cn.md)**
   - 详细的部署说明
   - 性能要求分析
   - 故障排查指南

## 📚 文档列表

### 快速部署

| 文档 | 说明 | 适合人群 |
|------|------|----------|
| [快速开始指南](./quick-start-cn.md) | 5分钟Docker部署 | 初学者、快速测试 |
| [环境变量示例](./env-examples-cn.md) | 配置文件模板 | 所有用户 |

### 详细指南

| 文档 | 说明 | 适合人群 |
|------|------|----------|
| [完整部署指南](./vps-deployment-guide-cn.md) | Docker+源码部署详解 | 进阶用户、生产环境 |
| [一键部署脚本说明](../../scripts/README-CN.md) | 自动化部署脚本 | 所有用户 |

## 🛠 一键部署脚本

### 腾讯云COS
```bash
curl -fsSL https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-tencent-cos.sh | bash
```

### 阿里云OSS
```bash
curl -fsSL https://raw.githubusercontent.com/stephengpope/no-code-architects-toolkit/main/scripts/deploy-vps-alibaba-oss.sh | bash
```

更多详情请参考：[脚本使用说明](../../scripts/README-CN.md)

## 📋 部署方式对比

### Docker部署（强烈推荐）

✅ **优点**:
- 5-10分钟快速部署
- 环境一致，避免依赖问题
- 易于管理和更新
- 自带所有依赖（FFmpeg等）

❌ **缺点**:
- 需要约1GB额外磁盘空间
- 轻微性能开销（约5-10%）

**推荐指南**: [快速开始指南](./quick-start-cn.md)

### 源码部署

✅ **优点**:
- 直接访问系统资源
- 可能略好的性能
- 便于开发和调试

❌ **缺点**:
- 需要1-2小时编译FFmpeg
- 环境配置复杂
- 维护更新麻烦

**推荐指南**: [完整部署指南](./vps-deployment-guide-cn.md) - 源码部署章节

## 💰 VPS性能要求

### 最低配置（测试用）
- CPU: 2核
- 内存: 4GB
- 硬盘: 40GB SSD
- 带宽: 5Mbps

### 推荐配置（生产用）
- CPU: 4核+
- 内存: 8GB+
- 硬盘: 80GB+ SSD
- 带宽: 10Mbps+

### 高性能配置（大文件/高并发）
- CPU: 8核+
- 内存: 16GB+
- 硬盘: 100GB+ NVMe
- 带宽: 50Mbps+

详细分析请参考：[完整部署指南 - VPS性能要求](./vps-deployment-guide-cn.md#vps性能要求)

## ☁️ 云存储配置

### 腾讯云COS

**快速配置**:
1. 创建存储桶: https://console.cloud.tencent.com/cos5
2. 获取密钥: https://console.cloud.tencent.com/cam/capi
3. 参考配置: [环境变量示例](./env-examples-cn.md#腾讯云cos配置)

**地域选择**: 广州、上海、北京、成都、深圳、香港等

### 阿里云OSS

**快速配置**:
1. 创建Bucket: https://oss.console.aliyun.com/
2. 创建AccessKey: https://ram.console.aliyun.com/users
3. 参考配置: [环境变量示例](./env-examples-cn.md#阿里云oss配置)

**地域选择**: 杭州、上海、青岛、北京、深圳、成都、香港等

## 🔧 常见问题

### Q1: 选择Docker还是源码部署？
**A**: 强烈推荐Docker！除非您需要开发或有特殊需求。

### Q2: VPS需要多大配置？
**A**: 最低2核4GB，推荐4核8GB。详见[性能要求](./vps-deployment-guide-cn.md#vps性能要求)

### Q3: 腾讯云COS和阿里云OSS如何选择？
**A**: 建议选择与VPS同一地域的服务商，可使用内网传输节省流量费。

### Q4: 部署需要多长时间？
**A**: 
- Docker部署：5-10分钟
- 源码部署：1-3小时（主要是编译FFmpeg）

### Q5: 如何降低成本？
**A**: 
- VPS与存储选同一地域，使用内网传输
- 配置对象生命周期自动删除
- 使用按需计费VPS

更多问题请参考：[故障排查](./vps-deployment-guide-cn.md#故障排查)

## 📞 获取帮助

### 官方资源
- **GitHub仓库**: https://github.com/stephengpope/no-code-architects-toolkit
- **API测试集**: https://bit.ly/49Gkh61
- **社区支持**: https://www.skool.com/no-code-architects

### 文档资源
- [完整部署指南](./vps-deployment-guide-cn.md) - 最详细的部署说明
- [快速开始指南](./quick-start-cn.md) - 快速上手
- [环境变量示例](./env-examples-cn.md) - 配置模板
- [脚本使用说明](../../scripts/README-CN.md) - 自动化部署

## 🎯 推荐阅读路径

### 路径1: 快速测试（15分钟）
1. 阅读[快速开始指南](./quick-start-cn.md)
2. 准备云存储（腾讯云或阿里云）
3. 运行一键部署脚本
4. 测试API

### 路径2: 生产部署（1小时）
1. 阅读[完整部署指南](./vps-deployment-guide-cn.md)
2. 准备VPS和域名
3. 配置云存储
4. Docker部署
5. 配置SSL证书
6. 性能调优
7. 监控和维护

### 路径3: 开发环境（2-3小时）
1. 阅读[完整部署指南 - 源码部署](./vps-deployment-guide-cn.md#源码部署)
2. 准备开发环境
3. 编译FFmpeg
4. 安装Python依赖
5. 配置开发工具
6. 调试和测试

## 🌟 成功案例参考

### 小型工作室（2核4GB）
- **成本**: ¥100/月（VPS）+ ¥50/月（存储）
- **配置**: Docker + 腾讯云COS + HTTP
- **用途**: 音频转录、视频处理
- **处理量**: 100小时/月

### 中型企业（4核8GB）
- **成本**: ¥250/月（VPS）+ ¥100/月（存储）
- **配置**: Docker + 阿里云OSS + SSL
- **用途**: 媒体处理API、自动化工作流
- **处理量**: 500小时/月

### 高性能应用（8核16GB）
- **成本**: ¥800/月（VPS）+ ¥200/月（存储）
- **配置**: 源码部署 + 腾讯云COS内网 + 负载均衡
- **用途**: 大规模媒体处理、AI转录
- **处理量**: 2000+小时/月

详细成本分析：[完整部署指南 - 成本估算](./vps-deployment-guide-cn.md#成本估算)

## 🔄 更新日志

### 2024-11
- 新增VPS部署完整指南
- 新增快速开始指南
- 新增环境变量配置示例
- 新增腾讯云COS一键部署脚本
- 新增阿里云OSS一键部署脚本
- 新增中文文档索引

## 📝 贡献

欢迎提交问题和改进建议！

- 提交Issue: https://github.com/stephengpope/no-code-architects-toolkit/issues
- 提交PR: 请提交到`build`分支

---

**开始您的部署之旅！从[快速开始指南](./quick-start-cn.md)开始吧 🚀**
