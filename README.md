# Docling Serve Enhanced - Full Image Support

An enhanced version of Docling Serve with proper image format support including MIME type detection and validation.

## Features

- ✅ Full support for all image formats that Docling supports (PNG, JPEG, GIF, TIFF, BMP, WebP, etc.)
- ✅ Automatic MIME type detection using content analysis
- ✅ Content-based file type validation
- ✅ Proper handling of files without extensions
- ✅ Enhanced logging for debugging
- ✅ Docker support with optimized image

## Supported Formats

### Images
- PNG (.png)
- JPEG/JPG (.jpeg, .jpg)
- GIF (.gif)
- TIFF (.tiff, .tif)
- BMP (.bmp)
- WebP (.webp)
- SVG (.svg)
- ICO (.ico)

### Documents
- PDF (.pdf)
- DOCX (.docx)
- PPTX (.pptx)
- XLSX (.xlsx)
- HTML (.html, .htm)
- Markdown (.md)
- Text (.txt)

### Audio
- WAV (.wav)
- MP3 (.mp3)

## Quick Start

### Using Docker Compose (CPU)

```bash
docker-compose up -d
```

### Using Docker Compose (GPU/CUDA)

For GPU acceleration with NVIDIA CUDA:

```bash
# Using the convenience script
./scripts/run-cuda.sh

# Or manually
docker-compose -f docker-compose.cuda.yml up -d
```

**Prerequisites for CUDA support:**
- NVIDIA GPU with CUDA support
- NVIDIA drivers installed
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

The service will be available at:
- API: http://localhost:5001
- API Documentation: http://localhost:5001/docs
- UI: http://localhost:5001/ui

### Using Docker

```bash
# Build the image
docker build -t docling-serve-enhanced .

# Run with UI enabled
docker run -p 5001:5001 -e DOCLING_SERVE_ENABLE_UI=1 docling-serve-enhanced

# Run with GPU support (CUDA)
docker run --gpus all -p 5001:5001 -e DOCLING_SERVE_ENABLE_UI=1 docling-serve-enhanced
```

### Local Installation with CUDA Support

```bash
# Quick setup with CUDA
./scripts/setup-cuda-local.sh

# Run with CUDA support
./scripts/run-local-cuda.sh
```

This will:
- Create a virtual environment
- Detect your CUDA version
- Install PyTorch with appropriate CUDA support
- Download EasyOCR models
- Configure GPU acceleration

### Using UV (Recommended)

```bash
# Install UV if you haven't already
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Run the server
uv run uvicorn app:app --host 0.0.0.0 --port 5001

# Or use the provided script
./scripts/run-local.sh
```

### Using pip

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python -m uvicorn app:app --host 0.0.0.0 --port 5001
```

## API Usage

### Convert an Image File

```bash
# Convert a PNG image to markdown
curl -X POST "http://localhost:5001/v1/convert/file" \
  -H "accept: application/json" \
  -F "files=@image.png" \
  -F 'options={"output_format": "markdown", "image_export_mode": "embedded"}'

# Convert multiple images
curl -X POST "http://localhost:5001/v1/convert/file" \
  -H "accept: application/json" \
  -F "files=@photo1.jpg" \
  -F "files=@photo2.png" \
  -F 'options={"output_format": "json"}'
```

### Convert from URL

```bash
curl -X POST "http://localhost:5001/v1/convert/source" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "sources": [
      {"kind": "http", "url": "https://example.com/image.png"}
    ],
    "options": {
      "output_format": "markdown",
      "image_export_mode": "referenced"
    }
  }'
```

## Configuration

Environment variables:

- `DOCLING_SERVE_ENABLE_UI`: Enable the Gradio UI (default: 1)
- `DOCLING_SERVE_MAX_DOCUMENT_SIZE`: Maximum file size in bytes (default: 50MB)
- `DOCLING_SERVE_MAX_SYNC_WAIT`: Maximum wait time for sync operations (default: 180s)
- `DOCLING_OCR_ENGINE`: OCR engine to use (default: easyocr)
- `DOCLING_OCR_USE_GPU`: Enable GPU acceleration for OCR (default: false, true in CUDA image)
- `CUDA_VISIBLE_DEVICES`: GPU device ID to use (default: 0)
- `DOCLING_SERVE_ENABLE_CORS`: Enable CORS (default: true)

## What's Enhanced?

1. **Proper MIME Type Detection**: Uses both filename and content-based detection
2. **No Hardcoded Extensions**: Dynamically determines file extensions based on content
3. **Better Error Handling**: Validates file types before processing
4. **Enhanced Logging**: Detailed logs for debugging file type issues
5. **Image-Optimized Docker**: Includes all necessary libraries for image processing

## Development

### Setup with UV

```bash
# Clone the repository
git clone https://github.com/yourusername/docling-enhanced.git
cd docling-enhanced

# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies including dev dependencies
uv sync --dev

# Run tests
uv run pytest tests/

# Run with hot reload
uv run uvicorn app:app --host 0.0.0.0 --port 5001 --reload
```

### Testing

Run the test suite:

```bash
# With UV
uv run pytest tests/

# With pip
python -m pytest tests/
```

Test image conversion:

```bash
# With UV
uv run python tests/test_image_support.py

# With pip
python tests/test_image_support.py
```

## License

MIT License (same as original Docling Serve)# docling-enhanced
