#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <pdf_file> [server_url] [api_key]"
    echo "Example: $0 document.pdf"
    echo "Example: $0 document.pdf http://localhost:8080"
    echo "Example: $0 document.pdf http://localhost:8080 your-api-key"
    exit 1
fi

PDF_FILE="$1"
SERVER_URL="${2:-http://localhost:8080}"
API_KEY="${3:-}"

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File '$PDF_FILE' not found"
    exit 1
fi

# Get the filename
FILENAME=$(basename "$PDF_FILE")

# Create temporary file for JSON request
TEMP_JSON=$(mktemp)
trap "rm -f $TEMP_JSON" EXIT

# Convert PDF to base64 and create JSON request
echo "Converting PDF to base64 and creating request..."
cat > "$TEMP_JSON" <<EOF
{
  "sources": [
    {
      "kind": "file",
      "base64_string": "$(base64 -i "$PDF_FILE" | tr -d '\n')",
      "filename": "$FILENAME"
    }
  ],
  "options": {}
}
EOF

# Build curl command with optional API key
echo "Sending request to: $SERVER_URL/v1/convert/source"
if [ -n "$API_KEY" ]; then
    curl -v -X POST \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -H "X-API-Key: $API_KEY" \
      --data-binary "@$TEMP_JSON" \
      "$SERVER_URL/v1/convert/source"
else
    curl -X POST \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data-binary "@$TEMP_JSON" \
      "$SERVER_URL/v1/convert/source"
fi

echo ""
