#!/bin/bash

# Test script for converting different file types

SERVER_URL="${1:-http://localhost:8000}"
API_KEY="${2:-}"

echo "Testing Docling conversions with different file types"
echo "Server: $SERVER_URL"
echo "----------------------------------------"

# Test CSV file
if [ -f "test_files/sample_data.csv" ]; then
    echo -e "\n1. Testing CSV file conversion:"
    ./convert_file.sh test_files/sample_data.csv "$SERVER_URL" "$API_KEY"
else
    echo -e "\n1. CSV test file not found"
fi

# Test PNG image
if [ -f "test_files/test_image.png" ]; then
    echo -e "\n2. Testing PNG image conversion:"
    ./convert_file.sh test_files/test_image.png "$SERVER_URL" "$API_KEY"
else
    echo -e "\n2. PNG test file not found"
fi

# Test text file
if [ -f "test_files/sample_text.txt" ]; then
    echo -e "\n3. Testing TXT file conversion:"
    ./convert_file.sh test_files/sample_text.txt "$SERVER_URL" "$API_KEY"
else
    echo -e "\n3. TXT test file not found"
fi

# Test XLSX file
if [ -f "test_files/sample_data.xlsx" ]; then
    echo -e "\n4. Testing XLSX file conversion:"
    ./convert_file.sh test_files/sample_data.xlsx "$SERVER_URL" "$API_KEY"
else
    echo -e "\n4. XLSX test file not found"
fi

# Test DOCX file
if [ -f "test_files/sample_document.docx" ]; then
    echo -e "\n5. Testing DOCX file conversion:"
    ./convert_file.sh test_files/sample_document.docx "$SERVER_URL" "$API_KEY"
else
    echo -e "\n5. DOCX test file not found"
fi

# Test PDF if available
if [ -f "test_files/test.pdf" ]; then
    echo -e "\n6. Testing PDF file conversion:"
    ./convert_pdf.sh test_files/test.pdf "$SERVER_URL" "$API_KEY"
else
    echo -e "\n6. PDF test file not found (you can add one to test_files/)"
fi

echo -e "\n----------------------------------------"
echo "Test completed"