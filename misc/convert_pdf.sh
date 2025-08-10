#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <pdf_file>"
    echo "Example: $0 document.pdf"
    exit 1
fi

PDF_FILE="$1"

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File '$PDF_FILE' not found"
    exit 1
fi

echo "Converting PDF: $PDF_FILE"
curl -X POST \
  -H "Content-Type: multipart/form-data" \
  -F "file=@$PDF_FILE" \
  http://localhost:8000/v1/convert/source

echo ""
