# 项目搭建完成后的用法总览

本文整理了 No-Code Architects Toolkit API 在完成部署后的全部核心能力，帮助你快速了解可以做什么、应该调用哪些接口、以及如何组合这些能力来构建自动化流程或内容生产流水线。建议在开始之前确保服务已经成功启动并且能够通过 `X-API-Key` 访问。

---

## 1. 环境确认与健康检查

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/toolkit/test`](toolkit/test.md) | 探活接口，校验 API 是否正常响应 | 部署后第一时间测试；用于监控或预警系统的健康检查 |
| [`/v1/toolkit/authenticate`](toolkit/authenticate.md) | 校验 `X-API-Key` 是否有效 | 在前端或自动化工具中快速验证密钥配置 |
| [`/v1/toolkit/job/status`](toolkit/job_status.md) | 根据 `job_id` 查询单个任务状态 | 轮询异步任务进度；失败重试时获取错误详情 |
| [`/v1/toolkit/jobs/status`](toolkit/jobs_status.md) | 批量查询时间范围内的任务列表 | 创建看板或可视化监控；统计处理量 |

> **提示**：所有接口默认支持 webhook。只要在请求体中携带 `webhook_url`，任务会异步执行并在完成后回调你的服务。

---

## 2. 功能清单（按场景分类）

### 2.1 音频处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/audio/concatenate`](audio/concatenate.md) | 将多段音频合并为单一文件 | 制作播客合集、把多段配音拼接成成片素材 |

### 2.2 视频处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/video/concatenate`](video/concatenate.md) | 多段视频顺序拼接 | 批量生成横版/竖版合集、短视频批量拼接 |
| [`/v1/video/cut`](video/cut.md) | 按时间剪切视频片段 | 批量裁剪素材、去除片头片尾 |
| [`/v1/video/trim`](video/trim.md) | 保留指定时间段 | 快速截取精华片段 |
| [`/v1/video/split`](video/split.md) | 拆分成多个切片 | 直播回放切割成多个短视频 |
| [`/v1/video/thumbnail`](video/thumbnail.md) | 抽取指定时间帧的缩略图 | 批量生成封面、用于社交媒体首图 |
| [`/v1/video/caption`](video/caption_video.md) | 为视频烧制 SRT/ASS 字幕并输出新文件 | 制作字幕版短视频、生成多语言版本 |

### 2.3 图像与网页

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/image/convert/video`](image/convert/image_to_video.md) | 单张图片生成带镜头运动的视频 | 将海报/宣传图转成动效视频、制作背景循环视频 |
| [`/v1/image/screenshot/webpage`](image/screenshot_webpage.md) | 通过 Playwright 截取网页 | 生成网站/落地页截图、制作 UI 素材、记录网页变更 |

### 2.4 字幕与文本

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/media_transcribe`](media/media_transcribe.md) | 调用 Whisper 转写/翻译音视频 | 生成逐字稿、制作字幕、跨语言翻译 |
| [`/v1/media/generate/ass`](media/generate_ass.md) | 基于原始媒体生成富样式 ASS 字幕 | 运营侧制作卡拉 OK 高亮字幕、配合 caption 接口烧制成片 |

### 2.5 通用媒体处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/convert`](media/convert/media_convert.md) | 通用音视频格式转换（Codec 自定义） | 标准化素材格式、批量转换分发格式 |
| [`/v1/media/convert/mp3`](media/convert/media_to_mp3.md) | 快速转 MP3 | 提取语音播客、生成音频摘要 |
| [`/v1/BETA/media/download`](media/download.md) | 通过 yt-dlp 抓取网络媒体 | 下载长视频原素材、抓取音频节目 |
| [`/v1/media/metadata`](media/metadata.md) | 获取媒体的详细参数 | 自动化质检、素材库入库前校验 |
| [`/v1/media/silence`](media/silence.md) | 检测静音片段 | 自动找出剪辑点、生成 B-roll 切换节点 |
| [`/v1/media/feedback`](media/feedback.md) | 生成带有 UI 的反馈页面 | 收集团队/客户对媒体的意见 |

### 2.6 云存储与交付

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/s3/upload`](s3/upload.md) | 直接从 URL 上传到 S3 兼容存储 | 将处理结果推送到 COS/OSS/MinIO；自动化备份 |
| `/gdrive-upload` | 将远程文件分块上传至 Google Drive（需要 `GDRIVE_USER` + `GCP_SA_CREDENTIALS`） | 与 Google Workspace 协同、产出物直接进团队盘 |

### 2.7 自动化工具箱

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/ffmpeg/compose`](ffmpeg/ffmpeg_compose.md) | 通过 JSON 描述任意 FFmpeg 流水线 | 高级媒体合成、批量模板渲染 |
| [`/audio-mixing`](../routes/audio_mixing.py) | 远程混合视频原声与配乐并调节音量 | 制作旁白版视频、构建播客+配乐混音 |

> `/audio-mixing` 尚无独立文档，功能由 `services/audio_mixing.py` 提供，支持 webhook、云端上传。

### 2.8 开发者与运维能力

| Endpoint / 功能 | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/code/execute/python`](code/execute/execute_python.md) | 远程安全地执行 Python 代码，返回标准输出和错误输出 | 构建自定义算子、在工作流中运行小型脚本 |
| 队列模式（`queue_task_wrapper`） | 无需自己管理后台任务队列，内置同步 / 异步 / Cloud Run 托管 | 避免请求超时、提升长任务稳定性 |
| Webhook 回调 | 任意接口加入 `webhook_url` 即启用 | 与 n8n/Make/Zapier 整合，任务完成自动触发下一步 |

---

## 3. 自动化集成玩法

1. **同步调用**：不携带 `webhook_url` 的请求会在同一 HTTP 响应中返回结果，适合 < 60 秒的快速处理。
2. **内置异步队列**：携带 `webhook_url` 时立即返回 `202`，后台处理完成后推送 webhook。可通过 `/v1/toolkit/job/status` 轮询状态。
3. **GCP Cloud Run Jobs**：设置 `GCP_JOB_NAME` + `GCP_JOB_LOCATION` 后，长任务会被转交给 Cloud Run Job 执行，实现无限时长的无服务器处理。
4. **自定义回调数据**：任务请求体中的 `id` 会原样带入响应与 webhook，可用于在外部系统中做关联。
5. **本地/容器化工作流**：结合 `docker-compose.local.minio.n8n.md` 中的 MinIO + n8n 示例，可在本地搭建端到端媒体自动化平台。

---

## 4. 组合玩法示例

1. **短视频字幕流水线**  
   `/v1/media/media_transcribe` → `/v1/media/generate/ass` → `/v1/video/caption` → `/v1/s3/upload`  
   自动完成转写、字幕样式生成、烧录与上传。

2. **播客多平台分发**  
   `/v1/media/convert`（统一格式） → `/v1/media/convert/mp3` → `/v1/media/metadata` → `/v1/s3/upload`  
   产出平台标准音频并附带元数据，方便自动上架。

3. **网页到视频宣传素材**  
   `/v1/image/screenshot/webpage` → `/v1/image/convert/video` → `/v1/video/thumbnail`  
   将网页截图生成滚动视频，并配套封面图。

4. **外部任务协同**  
   任意媒体处理接口 + `webhook_url` 指向 n8n/Make → 接收结果后执行后续自动化（写入表格、推送 Slack、触发再加工任务）。

---

## 5. 兼容保留接口（Legacy）

以下接口与 `v1` 版本提供相同或相似功能，主要用于兼容历史工作流。新项目推荐直接使用 `v1` 命名空间。

| Endpoint | 功能摘要 | 推荐替代 |
| --- | --- | --- |
| `/caption-video` | 视频烧字幕 | [`/v1/video/caption`](video/caption_video.md) |
| `/combine-videos` | 拼接视频 | [`/v1/video/concatenate`](video/concatenate.md) |
| `/extract-keyframes` | 提取关键帧图像 | 暂无 v1 对应，可直接使用此接口 |
| `/image-to-video` | 图片转视频 | [`/v1/image/convert/video`](image/convert/image_to_video.md) |
| `/media-to-mp3` | 媒体转 MP3 | [`/v1/media/convert/mp3`](media/convert/media_to_mp3.md) |
| `/transcribe-media` | 音视频转写 | [`/v1/media/media_transcribe`](media/media_transcribe.md) |
| `/authenticate` (GET) | 校验 API Key | [`/v1/toolkit/authenticate`](toolkit/authenticate.md) |

> 兼容接口同样支持 `webhook_url`、`id` 等参数，返回结构也遵循队列包装后的统一格式。

---

## 6. 参考资料与下一步

- [更详细的接口文档目录](../README.md#api-endpoints)
- [开发者指南：如何新增路由](adding_routes.md)
- [中文部署与运维文档合集](cloud-installation/README-CN.md)
- [MinIO + n8n 本地自动化示例](../docker-compose.local.minio.n8n.md)

完成以上功能梳理后，你可以根据业务需求选用相应接口，并利用 webhook、任务队列和云端存储等能力构建完整的 AI + 媒体处理自动化系统。
