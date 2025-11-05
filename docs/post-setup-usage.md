# 项目搭建完成后的用法总览

本文整理了 No-Code Architects Toolkit API 在完成部署后的全部核心能力，帮助你快速了解可以做什么、应该调用哪些接口、以及如何组合这些能力来构建自动化流程或内容生产流水线。建议在开始之前确保服务已经成功启动并且能够通过 `X-API-Key` 访问。

> **建议：** 先在终端中设置通用变量，后续示例可直接复制粘贴。
> ```bash
> BASE_URL="http://localhost:8080"
> API_KEY="your_api_key"
> ```
> 大多数接口为 `POST` 请求，请同时带上 `-H "Content-Type: application/json"` 与 `-H "X-API-Key: $API_KEY"` 头部。

所有同步接口（未传 `webhook_url`）会直接返回包含结果的 200 响应；当传入 `webhook_url` 时接口会返回 202 状态，并在后台完成处理后将最终结果以 webhook 回调或 `/v1/toolkit/job/status` 查询方式返回。

---

## 1. 环境确认与健康检查

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/toolkit/test`](toolkit/test.md) | 探活接口，校验 API 是否正常响应 | 部署后第一时间测试；用于监控或预警系统的健康检查 |
| [`/v1/toolkit/authenticate`](toolkit/authenticate.md) | 校验 `X-API-Key` 是否有效 | 在前端或自动化工具中快速验证密钥配置 |
| [`/v1/toolkit/job/status`](toolkit/job_status.md) | 根据 `job_id` 查询单个任务状态 | 轮询异步任务进度；失败重试时获取错误详情 |
| [`/v1/toolkit/jobs/status`](toolkit/jobs_status.md) | 批量查询时间范围内的任务列表 | 创建看板或可视化监控；统计处理量 |

#### 对应 cURL 与响应示例

**GET `/v1/toolkit/test`**

```bash
curl -X GET "$BASE_URL/v1/toolkit/test" \
  -H "X-API-Key: $API_KEY"
```

```json
{
  "endpoint": "/v1/toolkit/test",
  "code": 200,
  "job_id": "0f6e6c19-2b54-4b40-9ef2-9fb2c2c084f3",
  "message": "success",
  "response": "https://storage.example.com/jobs/0f6e6c19/test-success.txt",
  "pid": 12345,
  "queue_id": 140250100112,
  "run_time": 0.214,
  "queue_time": 0,
  "total_time": 0.214,
  "build_number": "204"
}
```

**GET `/v1/toolkit/authenticate`**

```bash
curl -X GET "$BASE_URL/v1/toolkit/authenticate" \
  -H "X-API-Key: $API_KEY"
```

```json
{
  "endpoint": "/authenticate",
  "code": 200,
  "job_id": "9ed20b62-0df6-468e-a287-3f0d8f9bc206",
  "message": "success",
  "response": "Authorized",
  "run_time": 0.002,
  "queue_time": 0,
  "total_time": 0.002,
  "queue_id": 140250100112,
  "build_number": "204"
}
```

**POST `/v1/toolkit/job/status`**

```bash
curl -X POST "$BASE_URL/v1/toolkit/job/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "job_id": "0f6e6c19-2b54-4b40-9ef2-9fb2c2c084f3"
  }'
```

```json
{
  "job_status": "done",
  "job_id": "0f6e6c19-2b54-4b40-9ef2-9fb2c2c084f3",
  "queue_id": 140250100112,
  "process_id": 12345,
  "response": {
    "endpoint": "/v1/toolkit/test",
    "code": 200,
    "job_id": "0f6e6c19-2b54-4b40-9ef2-9fb2c2c084f3",
    "response": "https://storage.example.com/jobs/0f6e6c19/test-success.txt",
    "message": "success",
    "pid": 12345,
    "queue_id": 140250100112,
    "run_time": 0.214,
    "queue_time": 0,
    "total_time": 0.214,
    "queue_length": 0,
    "build_number": "204"
  }
}
```

**POST `/v1/toolkit/jobs/status`**

```bash
curl -X POST "$BASE_URL/v1/toolkit/jobs/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "since_seconds": 3600
  }'
```

```json
{
  "0f6e6c19-2b54-4b40-9ef2-9fb2c2c084f3": "done",
  "b56df033-34a5-4093-b0f8-8f97d0a6451a": "running"
}
```

---

## 2. 功能清单（按场景分类）

> 所有以下示例均默认带上 `-H "Content-Type: application/json"` 与 `-H "X-API-Key: $API_KEY"` 头部。若示例包含 `webhook_url`，同步响应会是 `202 processing`，示例中将附上即时响应与最终回调示例。去掉 `webhook_url` 即可改为同步 200 响应。

### 2.1 音频处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/audio/concatenate`](audio/concatenate.md) | 将多段音频合并为单一文件 | 制作播客合集、把多段配音拼接成成片素材 |

**POST `/v1/audio/concatenate`**

```bash
curl -X POST "$BASE_URL/v1/audio/concatenate" \
  -d '{
    "audio_urls": [
      {"audio_url": "https://example.com/intro.mp3"},
      {"audio_url": "https://example.com/outro.mp3"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "audio-merge-001"
  }'
```

即时响应：

```json
{
  "code": 202,
  "id": "audio-merge-001",
  "job_id": "a9cb28e5-8222-4ef2-8513-0e45c8482f6a",
  "message": "processing",
  "pid": 12345,
  "queue_id": 140250100112,
  "queue_length": 0,
  "max_queue_length": "unlimited",
  "build_number": "204"
}
```

任务完成（webhook 回调或 `/v1/toolkit/job/status`）示例：

```json
{
  "endpoint": "/v1/audio/concatenate",
  "code": 200,
  "id": "audio-merge-001",
  "job_id": "a9cb28e5-8222-4ef2-8513-0e45c8482f6a",
  "response": "https://storage.example.com/outputs/audio/audio-merge-001.mp3",
  "message": "success",
  "pid": 12345,
  "queue_id": 140250100112,
  "run_time": 8.432,
  "queue_time": 0.731,
  "total_time": 9.163,
  "queue_length": 0,
  "build_number": "204"
}
```

### 2.2 视频处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/video/concatenate`](video/concatenate.md) | 多段视频顺序拼接 | 批量生成横版/竖版合集、短视频批量拼接 |
| [`/v1/video/cut`](video/cut.md) | 按时间剪切视频片段 | 批量裁剪素材、去除片头片尾 |
| [`/v1/video/trim`](video/trim.md) | 保留指定时间段 | 快速截取精华片段 |
| [`/v1/video/split`](video/split.md) | 拆分成多个切片 | 直播回放切割成多个短视频 |
| [`/v1/video/thumbnail`](video/thumbnail.md) | 抽取指定时间帧的缩略图 | 批量生成封面、用于社交媒体首图 |
| [`/v1/video/caption`](video/caption_video.md) | 为视频烧制 SRT/ASS 字幕并输出新文件 | 制作字幕版短视频、生成多语言版本 |

**POST `/v1/video/concatenate`**

```bash
curl -X POST "$BASE_URL/v1/video/concatenate" \
  -d '{
    "video_urls": [
      {"video_url": "https://example.com/clip1.mp4"},
      {"video_url": "https://example.com/clip2.mp4"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "video-merge-001"
  }'
```

任务完成示例：

```json
{
  "endpoint": "/v1/video/concatenate",
  "code": 200,
  "id": "video-merge-001",
  "job_id": "f1e3a6a2-5b87-4e02-8f4a-9c8672f356ce",
  "response": "https://storage.example.com/outputs/video/video-merge-001.mp4",
  "message": "success",
  "run_time": 42.517,
  "queue_time": 1.024,
  "total_time": 43.541,
  "queue_length": 0
}
```

**POST `/v1/video/cut`**

```bash
curl -X POST "$BASE_URL/v1/video/cut" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "cuts": [
      {"start": "00:00:05.000", "end": "00:00:15.000"},
      {"start": "00:00:30.000", "end": "00:00:45.000"}
    ],
    "video_codec": "libx264",
    "audio_codec": "aac",
    "webhook_url": "https://example.com/webhook",
    "id": "video-cut-001"
  }'
```

Webhook 回调：

```json
{
  "endpoint": "/v1/video/cut",
  "code": 200,
  "id": "video-cut-001",
  "job_id": "0f2f84c6-5af0-4c43-996c-2780c7568cf6",
  "response": "https://storage.example.com/outputs/video/video-cut-001.mp4",
  "message": "success",
  "run_time": 18.902,
  "queue_time": 0.63,
  "total_time": 19.532
}
```

**POST `/v1/video/trim`**

```bash
curl -X POST "$BASE_URL/v1/video/trim" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "start": "00:00:10.000",
    "end": "00:01:00.000",
    "webhook_url": "https://example.com/webhook",
    "id": "video-trim-001"
  }'
```

```json
{
  "endpoint": "/v1/video/trim",
  "code": 200,
  "id": "video-trim-001",
  "job_id": "1dcb635b-3a4f-4be3-b5c3-12b0ce7b58d8",
  "response": "https://storage.example.com/outputs/video/video-trim-001.mp4",
  "message": "success"
}
```

**POST `/v1/video/split`**

```bash
curl -X POST "$BASE_URL/v1/video/split" \
  -d '{
    "video_url": "https://example.com/webinar.mp4",
    "splits": [
      {"start": "00:00:00.000", "end": "00:00:30.000"},
      {"start": "00:00:30.000", "end": "00:01:00.000"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "video-split-001"
  }'
```

```json
{
  "endpoint": "/v1/video/split",
  "code": 200,
  "id": "video-split-001",
  "job_id": "d731f62f-5a58-4725-9a32-7f75ff8d4e21",
  "response": [
    {"file_url": "https://storage.example.com/outputs/video/video-split-001_part1.mp4"},
    {"file_url": "https://storage.example.com/outputs/video/video-split-001_part2.mp4"}
  ],
  "message": "success"
}
```

**POST `/v1/video/thumbnail`**

```bash
curl -X POST "$BASE_URL/v1/video/thumbnail" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "second": 12.5,
    "id": "video-thumb-001"
  }'
```

```json
{
  "endpoint": "/v1/video/thumbnail",
  "code": 200,
  "id": "video-thumb-001",
  "job_id": "6a4275c2-e30d-4c82-b9b9-02d332152755",
  "response": "https://storage.example.com/outputs/video/video-thumb-001.png",
  "message": "success"
}
```

**POST `/v1/video/caption`**

```bash
curl -X POST "$BASE_URL/v1/video/caption" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "srt": "1\\n00:00:00,000 --> 00:00:03,000\\nHello world!\\n",
    "options": [
      {"option": "-vf", "value": "scale=1280:720"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "video-caption-001"
  }'
```

```json
{
  "endpoint": "/v1/video/caption",
  "code": 200,
  "id": "video-caption-001",
  "job_id": "50f0ef85-a8bf-4bdf-8a2d-b14c6725dd88",
  "response": "https://storage.example.com/outputs/video/video-caption-001.mp4",
  "message": "success"
}
```

### 2.3 图像与网页

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/image/convert/video`](image/convert/image_to_video.md) | 单张图片生成带镜头运动的视频 | 将海报/宣传图转成动效视频、制作背景循环视频 |
| [`/v1/image/screenshot/webpage`](image/screenshot_webpage.md) | 通过 Playwright 截取网页 | 生成网站/落地页截图、制作 UI 素材、记录网页变更 |

**POST `/v1/image/convert/video`**

```bash
curl -X POST "$BASE_URL/v1/image/convert/video" \
  -d '{
    "image_url": "https://example.com/poster.jpg",
    "length": 8,
    "frame_rate": 30,
    "zoom_speed": 5,
    "webhook_url": "https://example.com/webhook",
    "id": "image-video-001"
  }'
```

```json
{
  "endpoint": "/v1/image/convert/video",
  "code": 200,
  "id": "image-video-001",
  "job_id": "f463f3a8-745e-40fc-8a65-1b8f95db08cc",
  "response": "https://storage.example.com/outputs/video/image-video-001.mp4",
  "message": "success"
}
```

**POST `/v1/image/screenshot/webpage`**

```bash
curl -X POST "$BASE_URL/v1/image/screenshot/webpage" \
  -d '{
    "url": "https://example.com",
    "viewport_width": 1280,
    "viewport_height": 720,
    "full_page": true,
    "format": "png",
    "delay": 1000,
    "webhook_url": "https://example.com/webhook",
    "id": "screenshot-001"
  }'
```

```json
{
  "endpoint": "/v1/image/screenshot/webpage",
  "code": 200,
  "id": "screenshot-001",
  "job_id": "36e7e9a5-4066-4c48-b2a0-d7d3c5f5d4f7",
  "response": "https://storage.example.com/outputs/image/screenshot-001.png",
  "message": "success"
}
```

### 2.4 字幕与文本

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/media_transcribe`](media/media_transcribe.md) | 调用 Whisper 转写/翻译音视频 | 生成逐字稿、制作字幕、跨语言翻译 |
| [`/v1/media/generate/ass`](media/generate_ass.md) | 基于原始媒体生成富样式 ASS 字幕 | 运营侧制作卡拉 OK 高亮字幕、配合 caption 接口烧制成片 |

**POST `/v1/media/transcribe`**

```bash
curl -X POST "$BASE_URL/v1/media/transcribe" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "task": "transcribe",
    "include_text": true,
    "include_srt": true,
    "response_type": "cloud",
    "language": "en",
    "webhook_url": "https://example.com/webhook",
    "id": "transcribe-001"
  }'
```

```json
{
  "endpoint": "/v1/transcribe/media",
  "code": 200,
  "id": "transcribe-001",
  "job_id": "c2cd90e5-0a12-4d8f-8470-557e77287cb4",
  "response": {
    "text": null,
    "srt": null,
    "segments": null,
    "text_url": "https://storage.example.com/outputs/text/transcribe-001.txt",
    "srt_url": "https://storage.example.com/outputs/subtitle/transcribe-001.srt",
    "segments_url": "https://storage.example.com/outputs/text/transcribe-001.json"
  },
  "message": "success"
}
```

**POST `/v1/media/generate/ass`**

```bash
curl -X POST "$BASE_URL/v1/media/generate/ass" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "canvas_width": 1920,
    "canvas_height": 1080,
    "language": "en",
    "settings": {
      "font_family": "Arial",
      "font_size": 48,
      "line_color": "&H00FFFFFF",
      "style": "karaoke"
    },
    "webhook_url": "https://example.com/webhook",
    "id": "ass-style-001"
  }'
```

```json
{
  "endpoint": "/v1/media/generate/ass",
  "code": 200,
  "id": "ass-style-001",
  "job_id": "e7a41a10-6b5a-4874-a66a-0a196ce8d6b3",
  "response": "https://storage.example.com/outputs/subtitle/ass-style-001.ass",
  "message": "success"
}
```

### 2.5 通用媒体处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/convert`](media/convert/media_convert.md) | 通用音视频格式转换（Codec 自定义） | 标准化素材格式、批量转换分发格式 |
| [`/v1/media/convert/mp3`](media/convert/media_to_mp3.md) | 快速转 MP3 | 提取语音播客、生成音频摘要 |
| [`/v1/BETA/media/download`](media/download.md) | 通过 yt-dlp 抓取网络媒体 | 下载长视频原素材、抓取音频节目 |
| [`/v1/media/metadata`](media/metadata.md) | 获取媒体的详细参数 | 自动化质检、素材库入库前校验 |
| [`/v1/media/silence`](media/silence.md) | 检测静音片段 | 自动找出剪辑点、生成 B-roll 切换节点 |
| [`/v1/media/feedback`](media/feedback.md) | 生成带有 UI 的反馈页面 | 收集团队/客户对媒体的意见 |

**POST `/v1/media/convert`**

```bash
curl -X POST "$BASE_URL/v1/media/convert" \
  -d '{
    "media_url": "https://example.com/source.mov",
    "format": "mp4",
    "video_codec": "libx264",
    "audio_codec": "aac",
    "webhook_url": "https://example.com/webhook",
    "id": "convert-001"
  }'
```

```json
{
  "endpoint": "/v1/media/convert",
  "code": 200,
  "id": "convert-001",
  "job_id": "b40f1137-6dcb-4b61-81a9-91c33e67d22a",
  "response": "https://storage.example.com/outputs/video/convert-001.mp4",
  "message": "success"
}
```

**POST `/v1/media/convert/mp3`**

```bash
curl -X POST "$BASE_URL/v1/media/convert/mp3" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "bitrate": "192k",
    "sample_rate": 44100,
    "webhook_url": "https://example.com/webhook",
    "id": "mp3-001"
  }'
```

```json
{
  "endpoint": "/v1/media/transform/mp3",
  "code": 200,
  "id": "mp3-001",
  "job_id": "de7c0f8f-9474-4d10-90e4-91ad7e35dfaf",
  "response": "https://storage.example.com/outputs/audio/mp3-001.mp3",
  "message": "success"
}
```

**POST `/v1/BETA/media/download`**

```bash
curl -X POST "$BASE_URL/v1/BETA/media/download" \
  -d '{
    "media_url": "https://www.youtube.com/watch?v=VIDEO_ID",
    "cloud_upload": true,
    "webhook_url": "https://example.com/webhook",
    "id": "download-001"
  }'
```

```json
{
  "endpoint": "/v1/BETA/media/download",
  "code": 200,
  "id": "download-001",
  "job_id": "28d6bfbe-7d9b-46ed-984a-4a8ea2f669d1",
  "response": {
    "file_url": "https://storage.example.com/outputs/video/download-001.mp4",
    "thumbnail_url": "https://storage.example.com/outputs/image/download-001.jpg",
    "duration": 612.48,
    "title": "Sample Video"
  },
  "message": "success"
}
```

**POST `/v1/media/metadata`**

```bash
curl -X POST "$BASE_URL/v1/media/metadata" \
  -d '{
    "media_url": "https://example.com/source.mp4",
    "id": "metadata-001"
  }'
```

```json
{
  "endpoint": "/v1/media/metadata",
  "code": 200,
  "id": "metadata-001",
  "job_id": "ae3fcb5f-b93c-4d44-a1ff-2fa049b04d4a",
  "response": {
    "format": {
      "duration": 59.97,
      "filesize": 157829432,
      "bitrate": 2100000
    },
    "video": {
      "codec": "h264",
      "width": 1920,
      "height": 1080,
      "fps": 29.97
    },
    "audio": {
      "codec": "aac",
      "channels": 2,
      "sample_rate": 48000
    }
  },
  "message": "success"
}
```

**POST `/v1/media/silence`**

```bash
curl -X POST "$BASE_URL/v1/media/silence" \
  -d '{
    "media_url": "https://example.com/podcast.mp3",
    "duration": 0.5,
    "noise": "-35dB",
    "mono": true,
    "webhook_url": "https://example.com/webhook",
    "id": "silence-001"
  }'
```

```json
{
  "endpoint": "/v1/media/silence",
  "code": 200,
  "id": "silence-001",
  "job_id": "76a8a8b5-afa0-4b74-bf84-697d08d3c732",
  "response": [
    {"start": 12.624, "end": 13.309},
    {"start": 58.451, "end": 60.002}
  ],
  "message": "success"
}
```

**GET `/v1/media/feedback`**

```bash
curl -L "$BASE_URL/v1/media/feedback"
```

响应为 HTML 页面，浏览器打开后可直接进行媒体反馈标注。

### 2.6 云存储与交付

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/s3/upload`](s3/upload.md) | 直接从 URL 上传到 S3 兼容存储 | 将处理结果推送到 COS/OSS/MinIO；自动化备份 |
| `/gdrive-upload` | 将远程文件分块上传至 Google Drive（需要 `GDRIVE_USER` + `GCP_SA_CREDENTIALS`） | 与 Google Workspace 协同、产出物直接进团队盘 |

**POST `/v1/s3/upload`**

```bash
curl -X POST "$BASE_URL/v1/s3/upload" \
  -d '{
    "file_url": "https://example.com/output.mp4",
    "filename": "campaign-final.mp4",
    "public": true
  }'
```

```json
{
  "endpoint": "/v1/s3/upload",
  "code": 200,
  "job_id": "c8899c44-0f02-4fb1-b437-1ef7ae1ac84f",
  "response": {
    "file_url": "https://oss.example.com/campaign-final.mp4",
    "bucket": "nca-toolkit",
    "key": "campaign-final.mp4",
    "public": true
  },
  "message": "success"
}
```

**POST `/gdrive-upload`**

```bash
curl -X POST "$BASE_URL/gdrive-upload" \
  -d '{
    "file_url": "https://example.com/output.mp4",
    "filename": "campaign-final.mp4",
    "folder_id": "YOUR_DRIVE_FOLDER_ID",
    "chunk_size": 5242880,
    "webhook_url": "https://example.com/webhook",
    "id": "gdrive-001"
  }'
```

```json
{
  "endpoint": "/gdrive-upload",
  "code": 200,
  "id": "gdrive-001",
  "job_id": "84dd8fa0-8e9d-4f16-8ef7-40dfc7d16df1",
  "response": {
    "file_id": "1r0xV2TgIaK9T3YJg5l9y5yL6uQmS0V7R",
    "share_url": "https://drive.google.com/file/d/1r0xV2TgIaK9T3YJg5l9y5yL6uQmS0V7R/view"
  },
  "message": "success"
}
```

### 2.7 自动化工具箱

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/ffmpeg/compose`](ffmpeg/ffmpeg_compose.md) | 通过 JSON 描述任意 FFmpeg 流水线 | 高级媒体合成、批量模板渲染 |
| [`/audio-mixing`](../routes/audio_mixing.py) | 远程混合视频原声与配乐并调节音量 | 制作旁白版视频、构建播客+配乐混音 |

**POST `/v1/ffmpeg/compose`**

```bash
curl -X POST "$BASE_URL/v1/ffmpeg/compose" \
  -d '{
    "inputs": [
      {
        "file_url": "https://example.com/clip.mp4",
        "options": [
          {"option": "-ss", "argument": 5},
          {"option": "-t", "argument": 15}
        ]
      }
    ],
    "outputs": [
      {
        "options": [
          {"option": "-c:v", "argument": "libx264"},
          {"option": "-preset", "argument": "medium"},
          {"option": "-crf", "argument": 23}
        ]
      }
    ],
    "global_options": [
      {"option": "-y"}
    ],
    "metadata": {
      "thumbnail": true,
      "duration": true
    },
    "webhook_url": "https://example.com/webhook",
    "id": "ffmpeg-001"
  }'
```

```json
{
  "endpoint": "/v1/ffmpeg/compose",
  "code": 200,
  "id": "ffmpeg-001",
  "job_id": "8a9946a3-b2c8-43a2-9f80-dbf7b1b41d01",
  "response": [
    {
      "file_url": "https://storage.example.com/outputs/video/ffmpeg-001.mp4",
      "duration": 15.0,
      "thumbnail_url": "https://storage.example.com/outputs/image/ffmpeg-001_thumbnail.jpg"
    }
  ],
  "message": "success"
}
```

**POST `/audio-mixing`**

```bash
curl -X POST "$BASE_URL/audio-mixing" \
  -d '{
    "video_url": "https://example.com/raw-video.mp4",
    "audio_url": "https://example.com/voiceover.mp3",
    "video_vol": 80,
    "audio_vol": 100,
    "output_length": "video",
    "webhook_url": "https://example.com/webhook",
    "id": "audio-mix-001"
  }'
```

```json
{
  "endpoint": "/audio-mixing",
  "code": 200,
  "id": "audio-mix-001",
  "job_id": "1fb3f244-44e1-4d8a-91c7-6690b27d1cf6",
  "response": "https://storage.example.com/outputs/video/audio-mix-001.mp4",
  "message": "success"
}
```

### 2.8 开发者与运维能力

| Endpoint / 功能 | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/code/execute/python`](code/execute/execute_python.md) | 远程安全地执行 Python 代码，返回标准输出和错误输出 | 构建自定义算子、在工作流中运行小型脚本 |
| 队列模式（`queue_task_wrapper`） | 无需自己管理后台任务队列，内置同步 / 异步 / Cloud Run 托管 | 避免请求超时、提升长任务稳定性 |
| Webhook 回调 | 任意接口加入 `webhook_url` 即启用 | 与 n8n/Make/Zapier 整合，任务完成自动触发下一步 |

**POST `/v1/code/execute/python`**

```bash
curl -X POST "$BASE_URL/v1/code/execute/python" \
  -d '{
    "code": "print(\"Hello from Toolkit\")\nreturn 42",
    "timeout": 60,
    "id": "python-001"
  }'
```

```json
{
  "endpoint": "/v1/code/execute/python",
  "code": 200,
  "id": "python-001",
  "job_id": "f9b6f255-4f4a-4e39-a7d0-0931c88d1112",
  "response": {
    "result": 42,
    "stdout": "Hello from Toolkit\n",
    "stderr": "",
    "exit_code": 0
  },
  "message": "success"
}
```

> 队列模式与 Webhook 回调为框架特性，直接在任意任务请求体中附加 `webhook_url`、`id` 等字段即可，无需单独的接口调用。若未提供 `webhook_url`，同步响应即包含 `response` 数据。

---

## 3. 如何获取 OSS / 云端文件链接？

1. **同步任务**：接口直接返回 `code: 200`，最终文件地址位于响应体 `response` 字段（可能是字符串 URL，或带 `file_url` 的对象/数组）。
2. **异步任务（带 webhook）**：首次请求返回 `202 processing`，最终的 webhook 回调或 `/v1/toolkit/job/status` 查询结果中 `response` 字段即为上传成功后的 OSS/S3/GCS 链接。
3. **S3 / OSS 上传接口**：返回值通常包含 `file_url`、`bucket`、`key` 等信息，直接使用 `file_url` 即可对外分发。如果配置为私有存储，可结合存储服务自身的签名规则生成临时访问链接。

---

## 4. 组合玩法拆解

以下示例展示完整流水线的调用顺序、请求示例与关键响应片段。

### 4.1 短视频字幕流水线

目标：实现转写 → ASS 样式字幕 → 烧录字幕 → 上传至 OSS。

1. **转写原始音视频** `/v1/media/transcribe`
   - 请求 `response_type: "cloud"`，同时存储文字与字幕文件。
   - 从结果中拿到 `text_url` 或 `srt_url`。

2. **生成富样式 ASS 字幕** `/v1/media/generate/ass`
   - 请求中引用上一步结果的 `media_url`（可为同一原视频），自定义字体、颜色、卡拉 OK 动效。
   - 返回 `ASS` 文件 URL。

3. **烧制字幕输出最终视频** `/v1/video/caption`
   - 请求中带上 `video_url` 与 `ass`（可以直接放文件内容，或先下载后传入）。
   - 返回烧制后的视频 URL。

4. **上传第三方存储** `/v1/s3/upload`
   - 将烧制后的视频 URL 直接推送到 OSS/COS/MinIO，获得最终可分享链接。

每个步骤都可带 `webhook_url`，流水线中只需在收到 webhook 后把下一步的请求加入自动化工具（n8n/Make/Zapier）。

### 4.2 播客多平台分发

1. **统一格式** `/v1/media/convert` → 输出平台标准 MP4/MP3。
2. **提取音频** `/v1/media/convert/mp3` → 生成播客音频。
3. **补充元数据** `/v1/media/metadata` → 获取时长、码率等信息。
4. **上传云存储** `/v1/s3/upload` → 最终用于 RSS 或平台分发。

利用 `id` 字段在每一步追踪同一任务，最终组合为一份完整的音频包和指向 OSS 的下载链接。

### 4.3 网页到视频宣传素材

1. **截图网页** `/v1/image/screenshot/webpage` → 获得静态图。
2. **图片变视频** `/v1/image/convert/video` → 做出带缓慢推拉的动效视频。
3. **生成缩略图** `/v1/video/thumbnail` → 取视频中的关键帧作为封面。

输出分别为：截图 PNG、动效 MP4、封面 PNG，可直接摆放到营销落地页或社交媒体素材库。

### 4.4 外部任务协同

1. 任意媒体处理接口（例如 `/v1/media/convert`）请求中携带 `webhook_url` 指向 n8n/Make/Zapier。
2. n8n/Make 工作流收到 webhook 后读取 `response` 字段中的文件地址或文字结果。
3. 后续步骤可以写入 Google Sheet、推送 Slack、调用自建 API、触发下一个视频处理任务等。

### 4.5 长视频批量拆条 & 快速发布

1. **切片**：调用 `/v1/video/split` 根据时间点拆出多个片段，返回数组形式的 `file_url`。
2. **封面生成**：遍历切片结果，对每个片段调用 `/v1/video/thumbnail` 生成缩略图并保存到 OSS。
3. **自动打标签**：对每个切片调用 `/v1/media/metadata` 获取分辨率、比特率、时长，用于生成标题/描述。
4. **一键发布**：将片段与缩略图通过 `/v1/s3/upload` 推送到对象存储，返回的公网 URL 可直接用于社交平台上传。

> 小技巧：在 `id` 中携带 `split-index` 等自定义字段，方便 webhook 识别属于哪一个子片段。

### 4.6 全量内容再利用（抓取 → 多格式 → 字幕）

1. **抓源**：使用 `/v1/BETA/media/download` 把长视频从 YouTube/Vimeo 等平台拉取到本地/云存储。
2. **格式规范化**：用 `/v1/media/convert` 转成统一分辨率与编码，确保后续流程兼容。
3. **音频拆分**：调用 `/v1/media/convert/mp3` 提取播客音频版本，供 RSS 或语音平台使用。
4. **转写+翻译**：用 `/v1/media/transcribe` 获取文字稿与时间轴，必要时设置 `task: "translate"` 生成多语言版本。
5. **高级字幕**：将文字结果交给 `/v1/media/generate/ass` 制作带样式的字幕，再通过 `/v1/video/caption` 烧制到视频。
6. **终端分发**：最后把所有产物（标准视频、字幕、音频、文案）分别上传至 `/v1/s3/upload`，统一沉淀在 OSS/COS/MinIO。

### 4.7 多语言字幕 & 样式 A/B 流水线

1. **基础转写**：使用 `/v1/media/transcribe`，指定 `response_type: "cloud"` 与 `include_srt: true`，取得原语言字幕与时间轴。
2. **自动翻译**：再次调用同一接口（或使用翻译模式）获取目标语言字幕文本。
3. **双版本字幕生成**：分别调用 `/v1/media/generate/ass` 生成不同风格（例如 `karaoke` vs `word_by_word`）的字幕文件，并在 `settings` 内调整字体、颜色、位置。
4. **批量烧制**：对每种风格调用 `/v1/video/caption`，得到多个风格化的视频版本。
5. **效果评估**：通过 `/v1/media/metadata` 获取每个版本的码率/大小确认平台兼容，再用 `/v1/s3/upload` 上传并统计 A/B 数据。

---

## 5. 进阶玩法示例

### 5.1 移除视频开头重复帧

利用 `/v1/ffmpeg/compose` 的 `filters` 参数调用 `mpdecimate` 与 `setpts`，可自动删除重复帧并重新对齐时间线。

```bash
curl -X POST "$BASE_URL/v1/ffmpeg/compose" \
  -d '{
    "inputs": [
      {"file_url": "https://example.com/repeated-intro.mp4"}
    ],
    "filters": [
      {"filter": "mpdecimate"},
      {"filter": "setpts=N/FRAME_RATE/TB"}
    ],
    "outputs": [
      {"options": [{"option": "-c:v", "argument": "libx264"}]}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "dedupe-frames-001"
  }'
```

最终响应：

```json
{
  "endpoint": "/v1/ffmpeg/compose",
  "code": 200,
  "response": [
    {
      "file_url": "https://storage.example.com/outputs/video/dedupe-frames-001.mp4",
      "duration": 43.2
    }
  ]
}
```

### 5.2 字幕逐字打字机效果

通过 `/v1/media/generate/ass` 的 `style: "word_by_word"` 配合 `position` 与 `max_words_per_line`，再用 `/v1/video/caption` 烧录即可实现逐字显示效果。

```bash
curl -X POST "$BASE_URL/v1/media/generate/ass" \
  -d '{
    "media_url": "https://example.com/voice.mp4",
    "settings": {
      "style": "word_by_word",
      "font_family": "Source Han Sans",
      "font_size": 64,
      "word_color": "&H00FFFFFF",
      "outline_color": "&H00404040",
      "max_words_per_line": 1,
      "position": "middle_center",
      "shadow_offset": 3
    },
    "webhook_url": "https://example.com/webhook",
    "id": "typewriter-sub-001"
  }'
```

随后将生成的 `.ass` 文件传入 `/v1/video/caption`：

```bash
curl -X POST "$BASE_URL/v1/video/caption" \
  -d '{
    "video_url": "https://example.com/voice.mp4",
    "ass": "https://storage.example.com/outputs/subtitle/typewriter-sub-001.ass",
    "webhook_url": "https://example.com/webhook",
    "id": "typewriter-sub-burn-001"
  }'
```

回调示例：

```json
{
  "endpoint": "/v1/video/caption",
  "code": 200,
  "response": "https://storage.example.com/outputs/video/typewriter-sub-burn-001.mp4"
}
```

### 5.3 精准居中、动效字幕模板

结合 `/v1/ffmpeg/compose` 的 `drawtext` 过滤器和 `/v1/media/generate/ass`，可以自定义字幕位置、动画、背景毛玻璃等效果。示例：

```bash
curl -X POST "$BASE_URL/v1/ffmpeg/compose" \
  -d '{
    "inputs": [
      {"file_url": "https://example.com/clip.mp4"},
      {"file_url": "https://storage.example.com/outputs/subtitle/typewriter-sub-001.ass",
       "options": [{"option": "-vf", "argument": "ass"}]}
    ],
    "outputs": [
      {"options": [{"option": "-c:v", "argument": "libx264"}]}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "advanced-caption-001"
  }'
```

### 5.4 多轨音视频打包

通过 `/audio-mixing` + `/v1/media/metadata` 可得到多轨合成后的视频与详尽的编码参数，便于上传到第三方平台要求的规格。

---

## 6. Legacy 接口（兼容保留）

| Endpoint | 功能摘要 | 推荐替代 |
| --- | --- | --- |
| `/caption-video` | 视频烧字幕 | [`/v1/video/caption`](video/caption_video.md) |
| `/combine-videos` | 拼接视频 | [`/v1/video/concatenate`](video/concatenate.md) |
| `/extract-keyframes` | 提取关键帧图像 | 暂无 v1 对应，可直接使用此接口 |
| `/image-to-video` | 图片转视频 | [`/v1/image/convert/video`](image/convert/image_to_video.md) |
| `/media-to-mp3` | 媒体转 MP3 | [`/v1/media/convert/mp3`](media/convert/media_to_mp3.md) |
| `/transcribe-media` | 音视频转写 | [`/v1/media/media_transcribe`](media/media_transcribe.md) |
| `/authenticate` (GET) | 校验 API Key | [`/v1/toolkit/authenticate`](toolkit/authenticate.md) |

> 兼容接口的响应结构与 v1 版本一致，依旧支持 `webhook_url` 与 `id` 字段。

---

## 7. 参考资料与下一步

- [更详细的接口文档目录](../README.md#api-endpoints)
- [开发者指南：如何新增路由](adding_routes.md)
- [中文部署与运维文档合集](cloud-installation/README-CN.md)
- [MinIO + n8n 本地自动化示例](../docker-compose.local.minio.n8n.md)

完成以上功能梳理后，你可以根据业务需求选用相应接口，并利用 webhook、任务队列和云端存储等能力构建完整的 AI + 媒体处理自动化系统。
