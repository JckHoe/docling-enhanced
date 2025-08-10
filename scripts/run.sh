#!/bin/bash

docker run -d \
  --name docling-enhanced \
  -p 5001:5001 \
  -v $(pwd)/data:/data \
  -v $(pwd)/logs:/app/logs \
  -v /tmp/docling:/tmp/docling \
  -e DOCLING_SERVE_ENABLE_UI=1 \
  -e DOCLING_SERVE_MAX_DOCUMENT_SIZE=52428800 \
  -e DOCLING_OCR_ENGINE=easyocr \
  ghcr.io/jckhoe/docling-enhanced:latest