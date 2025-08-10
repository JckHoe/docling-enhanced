FROM python:3.11-slim

LABEL org.opencontainers.image.source=https://github.com/jckhoe/docling-enhanced

# Install system dependencies for image processing and OCR
RUN apt-get update && apt-get install -y \
    # Basic tools
    wget \
    curl \
    git \
    # Image libraries
    libmagic1 \
    libgomp1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    # Image format libraries
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    # OCR dependencies
    tesseract-ocr \
    libtesseract-dev \
    # PDF processing
    poppler-utils \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

WORKDIR /app

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --frozen --no-install-project --no-dev

# Copy application code
COPY mime_detector.py .
COPY app.py .
COPY docling_serve/ ./docling_serve/
COPY pyproject.toml .
COPY uv.lock .
COPY README.md .

# Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Download EasyOCR models during build to avoid runtime delays
RUN uv run python -c "import easyocr; reader = easyocr.Reader(['en'], gpu=False)" || true

# Create necessary directories
RUN mkdir -p /tmp/docling /data

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DOCLING_SERVE_ENABLE_UI=1
ENV DOCLING_SERVE_MAX_DOCUMENT_SIZE=52428800
ENV DOCLING_SERVE_HOST=0.0.0.0
ENV DOCLING_SERVE_PORT=5001

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5001/health || exit 1

# Run the application
CMD ["uv", "run", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5001", "--workers", "1"]
