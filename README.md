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

### Using Docker Compose

```bash
docker-compose up -d
```

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

### Using Python

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
- `DOCLING_SERVE_ENABLE_CORS`: Enable CORS (default: true)

## What's Enhanced?

1. **Proper MIME Type Detection**: Uses both filename and content-based detection
2. **No Hardcoded Extensions**: Dynamically determines file extensions based on content
3. **Better Error Handling**: Validates file types before processing
4. **Enhanced Logging**: Detailed logs for debugging file type issues
5. **Image-Optimized Docker**: Includes all necessary libraries for image processing

## Testing

Run the test suite:

```bash
python -m pytest tests/
```

Test image conversion:

```bash
python tests/test_image_support.py
```

## License

MIT License (same as original Docling Serve)# docling-enhanced
