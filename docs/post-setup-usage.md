# 项目搭建完成后的用法总览

本文整理了 No-Code Architects Toolkit API 在完成部署后的全部核心能力，帮助你快速了解可以做什么、应该调用哪些接口、以及如何组合这些能力来构建自动化流程或内容生产流水线。建议在开始之前确保服务已经成功启动并且能够通过 `X-API-Key` 访问。

> **建议：** 先在终端中设置通用变量，后续示例可直接复制粘贴。
> ```bash
> BASE_URL="http://localhost:8080"
> API_KEY="your_api_key"
> ```
> 大多数接口为 `POST` 请求，请同时带上 `-H "Content-Type: application/json"` 与 `-H "X-API-Key: $API_KEY"` 头部。

---

## 1. 环境确认与健康检查

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/toolkit/test`](toolkit/test.md) | 探活接口，校验 API 是否正常响应 | 部署后第一时间测试；用于监控或预警系统的健康检查 |
| [`/v1/toolkit/authenticate`](toolkit/authenticate.md) | 校验 `X-API-Key` 是否有效 | 在前端或自动化工具中快速验证密钥配置 |
| [`/v1/toolkit/job/status`](toolkit/job_status.md) | 根据 `job_id` 查询单个任务状态 | 轮询异步任务进度；失败重试时获取错误详情 |
| [`/v1/toolkit/jobs/status`](toolkit/jobs_status.md) | 批量查询时间范围内的任务列表 | 创建看板或可视化监控；统计处理量 |

#### 对应 cURL 示例

**GET `/v1/toolkit/test`**

```bash
curl -X GET "$BASE_URL/v1/toolkit/test" \
  -H "X-API-Key: $API_KEY"
```

**GET `/v1/toolkit/authenticate`**

```bash
curl -X GET "$BASE_URL/v1/toolkit/authenticate" \
  -H "X-API-Key: $API_KEY"
```

**POST `/v1/toolkit/job/status`**

```bash
curl -X POST "$BASE_URL/v1/toolkit/job/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "job_id": "YOUR_JOB_ID"
  }'
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

> **提示**：所有接口默认支持 webhook。只要在请求体中携带 `webhook_url`，任务会异步执行并在完成后回调你的服务。

---

## 2. 功能清单（按场景分类）

### 2.1 音频处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/audio/concatenate`](audio/concatenate.md) | 将多段音频合并为单一文件 | 制作播客合集、把多段配音拼接成成片素材 |

#### 对应 cURL 示例

**POST `/v1/audio/concatenate`**

```bash
curl -X POST "$BASE_URL/v1/audio/concatenate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "audio_urls": [
      {"audio_url": "https://example.com/intro.mp3"},
      {"audio_url": "https://example.com/outro.mp3"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "audio-merge-001"
  }'
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

#### 对应 cURL 示例

**POST `/v1/video/concatenate`**

```bash
curl -X POST "$BASE_URL/v1/video/concatenate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_urls": [
      {"video_url": "https://example.com/clip1.mp4"},
      {"video_url": "https://example.com/clip2.mp4"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "video-merge-001"
  }'
```

**POST `/v1/video/cut`**

```bash
curl -X POST "$BASE_URL/v1/video/cut" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

**POST `/v1/video/trim`**

```bash
curl -X POST "$BASE_URL/v1/video/trim" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "start": "00:00:10.000",
    "end": "00:01:00.000",
    "webhook_url": "https://example.com/webhook",
    "id": "video-trim-001"
  }'
```

**POST `/v1/video/split`**

```bash
curl -X POST "$BASE_URL/v1/video/split" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

**POST `/v1/video/thumbnail`**

```bash
curl -X POST "$BASE_URL/v1/video/thumbnail" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "second": 12.5,
    "id": "video-thumb-001"
  }'
```

**POST `/v1/video/caption`**

```bash
curl -X POST "$BASE_URL/v1/video/caption" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

### 2.3 图像与网页

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/image/convert/video`](image/convert/image_to_video.md) | 单张图片生成带镜头运动的视频 | 将海报/宣传图转成动效视频、制作背景循环视频 |
| [`/v1/image/screenshot/webpage`](image/screenshot_webpage.md) | 通过 Playwright 截取网页 | 生成网站/落地页截图、制作 UI 素材、记录网页变更 |

#### 对应 cURL 示例

**POST `/v1/image/convert/video`**

```bash
curl -X POST "$BASE_URL/v1/image/convert/video" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "image_url": "https://example.com/poster.jpg",
    "length": 8,
    "frame_rate": 30,
    "zoom_speed": 5,
    "webhook_url": "https://example.com/webhook",
    "id": "image-video-001"
  }'
```

**POST `/v1/image/screenshot/webpage`**

```bash
curl -X POST "$BASE_URL/v1/image/screenshot/webpage" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

### 2.4 字幕与文本

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/media_transcribe`](media/media_transcribe.md) | 调用 Whisper 转写/翻译音视频 | 生成逐字稿、制作字幕、跨语言翻译 |
| [`/v1/media/generate/ass`](media/generate_ass.md) | 基于原始媒体生成富样式 ASS 字幕 | 运营侧制作卡拉 OK 高亮字幕、配合 caption 接口烧制成片 |

#### 对应 cURL 示例

**POST `/v1/media/transcribe`**

```bash
curl -X POST "$BASE_URL/v1/media/transcribe" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

**POST `/v1/media/generate/ass`**

```bash
curl -X POST "$BASE_URL/v1/media/generate/ass" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

### 2.5 通用媒体处理

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/media/convert`](media/convert/media_convert.md) | 通用音视频格式转换（Codec 自定义） | 标准化素材格式、批量转换分发格式 |
| [`/v1/media/convert/mp3`](media/convert/media_to_mp3.md) | 快速转 MP3 | 提取语音播客、生成音频摘要 |
| [`/v1/BETA/media/download`](media/download.md) | 通过 yt-dlp 抓取网络媒体 | 下载长视频原素材、抓取音频节目 |
| [`/v1/media/metadata`](media/metadata.md) | 获取媒体的详细参数 | 自动化质检、素材库入库前校验 |
| [`/v1/media/silence`](media/silence.md) | 检测静音片段 | 自动找出剪辑点、生成 B-roll 切换节点 |
| [`/v1/media/feedback`](media/feedback.md) | 生成带有 UI 的反馈页面 | 收集团队/客户对媒体的意见 |

#### 对应 cURL 示例

**POST `/v1/media/convert`**

```bash
curl -X POST "$BASE_URL/v1/media/convert" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/source.mov",
    "format": "mp4",
    "video_codec": "libx264",
    "audio_codec": "aac",
    "webhook_url": "https://example.com/webhook",
    "id": "convert-001"
  }'
```

**POST `/v1/media/convert/mp3`**

```bash
curl -X POST "$BASE_URL/v1/media/convert/mp3" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "bitrate": "192k",
    "sample_rate": 44100,
    "webhook_url": "https://example.com/webhook",
    "id": "mp3-001"
  }'
```

**POST `/v1/BETA/media/download`**

```bash
curl -X POST "$BASE_URL/v1/BETA/media/download" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://www.youtube.com/watch?v=VIDEO_ID",
    "cloud_upload": true,
    "webhook_url": "https://example.com/webhook",
    "id": "download-001"
  }'
```

**POST `/v1/media/metadata`**

```bash
curl -X POST "$BASE_URL/v1/media/metadata" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/source.mp4",
    "id": "metadata-001"
  }'
```

**POST `/v1/media/silence`**

```bash
curl -X POST "$BASE_URL/v1/media/silence" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/podcast.mp3",
    "duration": 0.5,
    "noise": "-35dB",
    "mono": true,
    "webhook_url": "https://example.com/webhook",
    "id": "silence-001"
  }'
```

**GET `/v1/media/feedback`**

```bash
curl -L "$BASE_URL/v1/media/feedback"
```

### 2.6 云存储与交付

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/s3/upload`](s3/upload.md) | 直接从 URL 上传到 S3 兼容存储 | 将处理结果推送到 COS/OSS/MinIO；自动化备份 |
| `/gdrive-upload` | 将远程文件分块上传至 Google Drive（需要 `GDRIVE_USER` + `GCP_SA_CREDENTIALS`） | 与 Google Workspace 协同、产出物直接进团队盘 |

#### 对应 cURL 示例

**POST `/v1/s3/upload`**

```bash
curl -X POST "$BASE_URL/v1/s3/upload" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "file_url": "https://example.com/output.mp4",
    "filename": "campaign-final.mp4",
    "public": true
  }'
```

**POST `/gdrive-upload`**

```bash
curl -X POST "$BASE_URL/gdrive-upload" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "file_url": "https://example.com/output.mp4",
    "filename": "campaign-final.mp4",
    "folder_id": "YOUR_DRIVE_FOLDER_ID",
    "chunk_size": 5242880,
    "webhook_url": "https://example.com/webhook",
    "id": "gdrive-001"
  }'
```

### 2.7 自动化工具箱

| Endpoint | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/ffmpeg/compose`](ffmpeg/ffmpeg_compose.md) | 通过 JSON 描述任意 FFmpeg 流水线 | 高级媒体合成、批量模板渲染 |
| [`/audio-mixing`](../routes/audio_mixing.py) | 远程混合视频原声与配乐并调节音量 | 制作旁白版视频、构建播客+配乐混音 |

> `/audio-mixing` 尚无独立文档，功能由 `services/audio_mixing.py` 提供，支持 webhook、云端上传。

#### 对应 cURL 示例

**POST `/v1/ffmpeg/compose`**

```bash
curl -X POST "$BASE_URL/v1/ffmpeg/compose" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

**POST `/audio-mixing`**

```bash
curl -X POST "$BASE_URL/audio-mixing" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
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

### 2.8 开发者与运维能力

| Endpoint / 功能 | 功能摘要 | 常见玩法 |
| --- | --- | --- |
| [`/v1/code/execute/python`](code/execute/execute_python.md) | 远程安全地执行 Python 代码，返回标准输出和错误输出 | 构建自定义算子、在工作流中运行小型脚本 |
| 队列模式（`queue_task_wrapper`） | 无需自己管理后台任务队列，内置同步 / 异步 / Cloud Run 托管 | 避免请求超时、提升长任务稳定性 |
| Webhook 回调 | 任意接口加入 `webhook_url` 即启用 | 与 n8n/Make/Zapier 整合，任务完成自动触发下一步 |

#### 对应 cURL 示例

**POST `/v1/code/execute/python`**

```bash
curl -X POST "$BASE_URL/v1/code/execute/python" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "code": "print(\"Hello from Toolkit\")\nreturn 42",
    "timeout": 60,
    "id": "python-001"
  }'
```

> 队列模式与 Webhook 回调为框架特性，直接在任意任务请求体中附加 `webhook_url`、`id` 等字段即可，无需单独的接口调用。

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

#### 对应 cURL 示例（Legacy）

**POST `/caption-video`**

```bash
curl -X POST "$BASE_URL/caption-video" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "srt": "1\\n00:00:00,000 --> 00:00:03,000\\nHello world!\\n",
    "options": [
      {"option": "-vf", "value": "scale=1080:-2"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-caption-001"
  }'
```

**POST `/combine-videos`**

```bash
curl -X POST "$BASE_URL/combine-videos" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_urls": [
      {"video_url": "https://example.com/clip1.mp4"},
      {"video_url": "https://example.com/clip2.mp4"}
    ],
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-combine-001"
  }'
```

**POST `/extract-keyframes`**

```bash
curl -X POST "$BASE_URL/extract-keyframes" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "video_url": "https://example.com/source.mp4",
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-keyframes-001"
  }'
```

**POST `/image-to-video`**

```bash
curl -X POST "$BASE_URL/image-to-video" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "image_url": "https://example.com/poster.jpg",
    "length": 6,
    "frame_rate": 30,
    "zoom_speed": 4,
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-image-video-001"
  }'
```

**POST `/media-to-mp3`**

```bash
curl -X POST "$BASE_URL/media-to-mp3" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "bitrate": "160k",
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-mp3-001"
  }'
```

**POST `/transcribe-media`**

```bash
curl -X POST "$BASE_URL/transcribe-media" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "media_url": "https://example.com/interview.mp4",
    "output": "srt",
    "max_chars": 56,
    "webhook_url": "https://example.com/webhook",
    "id": "legacy-transcribe-001"
  }'
```

**GET `/authenticate`**

```bash
curl -X GET "$BASE_URL/authenticate" \
  -H "X-API-Key: $API_KEY"
```

> 兼容接口同样支持 `webhook_url`、`id` 等参数，返回结构也遵循队列包装后的统一格式。

---

## 6. 参考资料与下一步

- [更详细的接口文档目录](../README.md#api-endpoints)
- [开发者指南：如何新增路由](adding_routes.md)
- [中文部署与运维文档合集](cloud-installation/README-CN.md)
- [MinIO + n8n 本地自动化示例](../docker-compose.local.minio.n8n.md)

完成以上功能梳理后，你可以根据业务需求选用相应接口，并利用 webhook、任务队列和云端存储等能力构建完整的 AI + 媒体处理自动化系统。
