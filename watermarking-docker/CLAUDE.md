# watermarking-docker

## Current Work (Dec 2025)

### Progress Reporting - DONE

Added real-time progress updates during watermark embedding:

- **mark.cpp**: Outputs `PROGRESS:loading`, `PROGRESS:marking:n:total`, `PROGRESS:saving` to stdout
- **marking-queues.js**: Uses `spawn()` to stream stdout, parses progress, updates Firestore
- **storage-helper.js**: Added `getSignedUrl()` for 10-year signed URLs
- **Firestore**: Progress written to `/markedImages/{id}.progress`, cleared on completion

The pipeline works end-to-end but...

### Performance Problem - BLOCKING

The watermarking algorithm is **extremely slow** on CPU. A small avatar image with a 4-character message takes **hours** to process, hitting Cloud Run's 1-hour timeout.

**Root cause**: `insertMark()` in `WatermarkDetection.cpp` does 2 full-image DFTs per character:
```cpp
cv::dft(mat, mat, ...);            // Forward DFT on FULL image
// add watermark in frequency domain
cv::dft(mat, mat, DFT_INVERSE...); // Inverse DFT
```

For a 1000×1000 image, each DFT is ~20M operations. A 4-shift message = 8 full-image DFTs.

### Optimization Options

Discuss with Andrew Tirkel (inventor of digital watermark) before implementing:

| Optimization | Speedup | Effort | Quality/Robustness Impact |
|--------------|---------|--------|---------------------------|
| **Batch watermarks in freq domain** | ~Nx | Medium | None - mathematically equivalent |
| Downsample to 512×512 | ~4x | Easy | Slight reduction |
| Downsample to 256×256 | ~16x | Easy | Moderate reduction |
| Use optimal DFT size (power of 2) | ~2x | Easy | None |
| OpenCV with TBB/IPP | ~2-4x | Build flag | None |
| GPU acceleration (CUDA/OpenCL) | ~10-100x | High | None |
| Move to GCE VM (no timeout) | N/A | Low | None |

#### Batch Watermarks (Biggest Win)

Current approach (2N DFTs for N shifts):
```
DFT → add wm1 → IDFT → DFT → add wm2 → IDFT → DFT → add wm3 → IDFT → ...
```

Optimized approach (2 DFTs total):
```
DFT → add (wm1 + wm2 + wm3 + ...) → IDFT
```

Since addition is linear, adding watermarks in the frequency domain then doing a single IDFT is mathematically equivalent. This alone could give Nx speedup where N = number of shifts.

#### GPU Acceleration

The DFT is embarrassingly parallel. Options:
- **OpenCV CUDA**: Rebuild with CUDA, use `cv::cuda::dft()`
- **Cloud Run GPU**: Now supports nvidia-l4 GPUs
- **cuFFT**: NVIDIA's CUDA FFT library directly

---

## Current Status (Dec 2025)

**Deployed to Cloud Run**: https://watermarking-backend-78940960204.us-central1.run.app

### Recent Migration: Realtime Database → Firestore

Migrated from Firebase Realtime Database to Firestore:

- **Replaced** `firebase-queue` library with custom Firestore listener (`task-queue.js`)
- **Rewrote** all queue files for async/await pattern
- **Updated** Firebase project from `watermarking-print-and-scan` to `watermarking-4a428`
- **Removed** legacy dependencies (`firebase-queue`, `firebase` client SDK)

### Build & Deploy

```bash
# Build for Cloud Run (AMD64 - required for Cloud Run)
docker buildx build --platform linux/amd64 -f Dockerfile.cloudrun \
  -t gcr.io/watermarking-4a428/watermarking-cloudrun --push .

# Deploy
gcloud run deploy watermarking-backend \
  --image gcr.io/watermarking-4a428/watermarking-cloudrun:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Check logs
gcloud logging read 'resource.type="cloud_run_revision" resource.labels.service_name="watermarking-backend"' \
  --project=watermarking-4a428 --limit=30

# Health check
curl https://watermarking-backend-78940960204.us-central1.run.app/health
```

### Firestore Collections

```
/tasks
  - type: 'mark' | 'detect' | 'get_serving_url'
  - status: 'pending' | 'processing' | 'completed' | 'failed'
  - userId, createdAt, ...task-specific fields

/originalImages
  - userId, name, path, servingUrl, width, height, timestamp

/markedImages
  - originalImageId, userId, message, name, strength, path, servingUrl

/detecting/{userId}
  - progress, isDetecting, results

/users/{userId}
  - name, email
```

### Configuration

- **GCS Bucket**: `watermarking-4a428.firebasestorage.app`
- **Service Account**: `firebase-service-account.json`
- **Health Endpoint**: `GET /` or `GET /health`

---

## Purpose

Backend processing service for watermark marking and detection. Listens to Firestore task queue, downloads images from Google Cloud Storage, processes them with C++ programs using OpenCV watermarking algorithms, and uploads results back to GCS and Firestore.

## Tech Stack

- **Backend**: Node.js (listener service)
- **Image Processing**: C++ with OpenCV
- **Queue System**: Custom Firestore listener (replaced firebase-queue)
- **Database**: Cloud Firestore
- **Storage**: Google Cloud Storage (@google-cloud/storage SDK)
- **Notifications**: Twilio SMS
- **Deployment**: Docker on Cloud Run

## Architecture

### File Structure

```
├── listener.js              # HTTP server + task queue setup
├── task-queue.js            # Firestore listener for /tasks collection
├── marking-queues.js        # Watermark embedding logic
├── detection-queues.js      # Watermark detection logic
├── misc-queues.js           # Utility tasks (serving URLs, etc.)
├── firebase-admin-singleton.js  # Firebase/Firestore init
├── storage-helper.js        # GCS upload/download via SDK
├── tools.js                 # SMS notifications, serving URL helper
├── mark.cpp                 # C++ source for watermark embedding
├── detect.cpp               # C++ source for watermark detection
├── watermarking-functions/  # C++ library (copied from sibling dir)
├── Dockerfile.cloudrun      # Production build for Cloud Run
└── firebase-service-account.json  # Service account credentials
```

### Task Processing Flow

1. Flutter app writes task to `/tasks` with `status: 'pending'`
2. Backend Firestore listener (`task-queue.js`) picks up new pending tasks
3. Updates status to `'processing'`
4. Executes task based on `type`:
   - `mark`: Download → Run mark-image binary → Upload → Update markedImages
   - `detect`: Download both images → Run detect-wm → Update detecting/{userId}
   - `get_serving_url`: Get CDN URL → Update originalImages
5. Updates status to `'completed'` or `'failed'`

## JavaScript Files

### listener.js
Entry point. Creates HTTP server for Cloud Run health checks, initializes task queue.

### task-queue.js (NEW)
Custom Firestore-based queue replacing firebase-queue:
- Listens to `/tasks` collection with `status == 'pending'`
- Processes tasks based on `type` field
- Updates status through lifecycle: pending → processing → completed/failed
- Handles graceful shutdown on SIGTERM

### marking-queues.js
Exports `processMarkingTask(data)`:
1. Downloads original image from GCS
2. Runs `./mark-image` binary with message and strength
3. Uploads marked image to GCS
4. Gets serving URL
5. Updates `/markedImages/{id}` with result

### detection-queues.js
Exports `processDetectionTask(data)`:
1. Downloads original and marked images
2. Updates progress in `/detecting/{userId}`
3. Runs `./detect-wm` binary
4. Parses results JSON
5. Updates detection results

### misc-queues.js
Exports utility task handlers:
- `processServingUrlTask()`: Gets CDN serving URL for images
- `processVerifyUserTask()`: Admin user verification
- `processNotifyAdminTask()`: SMS notification for verification requests

### firebase-admin-singleton.js
Initializes Firebase Admin SDK with service account. Exports:
- `getAdmin()`: Firebase Admin instance
- `getFirestore()`: Firestore database instance

### storage-helper.js
GCS operations using @google-cloud/storage SDK:
- `downloadFile(gcsPath, localPath, callback)`
- `uploadFile(localPath, gcsPath, callback)`

### tools.js
Utility functions:
- `getServingUrl(path, callback)`: Fetches CDN URL from App Engine endpoint
- `sendSMStoAndrew(message)`: Twilio SMS
- `sendSMStoNick(message)`: Twilio SMS for errors

## C++ Programs

### mark.cpp
Embeds invisible watermarks using frequency domain techniques.

**Usage**: `./mark-image <filePath> <imageName> <message> <strength>`

**Process**:
1. Reads image, converts to HSV
2. Extracts luma (V channel)
3. For each message character: generates watermark array, embeds at calculated position
4. Saves as `{filePath}-marked.png`

### detect.cpp
Detects and extracts watermarks.

**Usage**: `./detect-wm <uid> <originalPath> <markedPath>`

**Process**:
1. Compares original and marked images
2. Extracts watermark from frequency domain
3. Correlates against known patterns
4. Outputs results to `/tmp/{uid}.json`

**Exit Codes**: 0 = success, 254 = size mismatch

## Processing Flows

### Marking Flow
```
Flutter app creates task → Firestore /tasks (status: pending)
  ↓
task-queue.js picks up task, sets status: processing
  ↓
marking-queues.js:
  1. Download from GCS: gs://watermarking-4a428.appspot.com/{path}
  2. Execute: ./mark-image {filePath} {name} {message} {strength}
  3. Upload to GCS: marked-images/{userId}/{timestamp}/{name}.png
  4. Get serving URL
  5. Update Firestore: /markedImages/{id}
  ↓
task-queue.js sets status: completed
```

### Detection Flow
```
Flutter app creates task → Firestore /tasks (status: pending)
  ↓
task-queue.js picks up task
  ↓
detection-queues.js:
  1. Update /detecting/{userId} progress
  2. Download original and marked images
  3. Execute: ./detect-wm {userId} {originalPath} {markedPath}
  4. Read /tmp/{userId}.json results
  5. Update /detecting/{userId} with results
  ↓
task-queue.js sets status: completed
```

## External Services

### Firebase/Firestore
- **Project**: watermarking-4a428
- **Service Account**: firebase-service-account.json

### Google Cloud Storage
- **Bucket**: watermarking-4a428.appspot.com
- **Original images**: `originals/{userId}/{filename}`
- **Marked images**: `marked-images/{userId}/{timestamp}/{name}.png`

### Twilio SMS
- Error notifications to Nick
- User verification notifications to Andrew

### App Engine Serving URLs
- **Endpoint**: https://watermarking-4a428.appspot.com/serving-url?path={encodedPath}
- **Purpose**: Generate optimized CDN URLs for images

## Build Prerequisites

Populate `watermarking-functions/` directory before building:
```bash
cp -r ../watermarking-functions/*.cpp ./watermarking-functions/
cp -r ../watermarking-functions/*.hpp ./watermarking-functions/
```

Required files:
- WatermarkDetection.cpp / .hpp
- Utilities.cpp / .hpp
- json.hpp

## TODO

- [x] Test full marking flow end-to-end (works, but too slow)
- [x] Add progress reporting to marking flow
- [ ] **Optimize marking performance** (discuss with Andrew Tirkel)
- [ ] Test detection flow
- [ ] Add Firestore security rules
- [ ] Add retry logic for failed tasks
- [ ] Clean up old Dockerfile variants (Dockerfile, Dockerfile1, Dockerfile2)
