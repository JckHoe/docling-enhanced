#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file> [server_url] [api_key]"
    echo "Example: $0 document.pdf"
    echo "Example: $0 image.png http://localhost:8080"
    echo "Example: $0 data.csv http://localhost:8080 your-api-key"
    exit 1
fi

FILE_PATH="$1"
SERVER_URL="${2:-http://localhost:8000}"
API_KEY="${3:-}"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found"
    exit 1
fi

# Get the filename
FILENAME=$(basename "$FILE_PATH")

# Create temporary file for JSON request
TEMP_JSON=$(mktemp)
trap "rm -f $TEMP_JSON" EXIT

# Convert file to base64 and create JSON request
echo "Converting file to base64 and creating request..."
cat > "$TEMP_JSON" <<EOF
{
  "sources": [
    {
      "kind": "file",
      "base64_string": "$(base64 -i "$FILE_PATH" | tr -d '\n')",
      "filename": "$FILENAME"
    }
  ],
  "options": {}
}
EOF

# Build curl command with optional API key
echo "Sending request to: $SERVER_URL/v1/convert/source"
if [ -n "$API_KEY" ]; then
    curl -X POST \
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