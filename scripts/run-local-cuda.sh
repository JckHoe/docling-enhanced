#!/bin/bash

# Script to run Docling Enhanced locally with CUDA support using uv

echo "Docling Enhanced - Local CUDA Setup (uv)"
echo "========================================"
echo ""

# Check if NVIDIA GPU is available
if ! command -v nvidia-smi &> /dev/null; then
    echo "Warning: nvidia-smi not found. NVIDIA drivers may not be installed."
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "GPU Info:"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
    echo ""
fi

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Python version: $PYTHON_VERSION"
echo ""

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    if ! command -v uv &> /dev/null; then
        echo "Error: Failed to install uv. Please install it manually:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
fi

echo "Using uv version: $(uv --version)"
echo ""

# Sync dependencies with uv
echo "Installing dependencies with uv..."
uv sync

# Check if CUDA is available and install appropriate PyTorch
echo ""
echo "Checking CUDA availability..."
CUDA_AVAILABLE=$(uv run python -c "import torch 2>/dev/null && print(torch.cuda.is_available())" 2>/dev/null || echo "False")

if [[ "$CUDA_AVAILABLE" != "True" ]] && command -v nvidia-smi &> /dev/null; then
    CUDA_VERSION=$(nvidia-smi | grep -oP "CUDA Version: \K[0-9]+\.[0-9]+" | head -1)
    echo "CUDA $CUDA_VERSION detected but PyTorch doesn't have CUDA support."
    echo "Installing PyTorch with CUDA support..."
    
    if [[ "$CUDA_VERSION" == "12."* ]]; then
        echo "Installing PyTorch for CUDA 12.x..."
        uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    elif [[ "$CUDA_VERSION" == "11."* ]]; then
        echo "Installing PyTorch for CUDA 11.x..."
        uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    else
        echo "Unsupported CUDA version: $CUDA_VERSION"
    fi
fi

# Verify CUDA setup
echo ""
echo "Verifying CUDA setup..."
uv run python -c "
import torch
import sys

if torch.cuda.is_available():
    print(f'✓ CUDA is available')
    print(f'  PyTorch version: {torch.__version__}')
    print(f'  CUDA version: {torch.version.cuda}')
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
    print(f'  GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB')
else:
    print('✗ CUDA is not available - will run on CPU')
    print(f'  PyTorch version: {torch.__version__}')
"

# Set environment variables
echo ""
echo "Setting environment variables..."
export PYTHONUNBUFFERED=1
export DOCLING_SERVE_ENABLE_UI=1
export DOCLING_SERVE_MAX_DOCUMENT_SIZE=52428800
export DOCLING_SERVE_HOST=127.0.0.1
export DOCLING_SERVE_PORT=5001
export DOCLING_OCR_USE_GPU=true
export CUDA_VISIBLE_DEVICES=0

# Create necessary directories
mkdir -p /tmp/docling data logs

# Start the application
echo ""
echo "Starting Docling Enhanced with CUDA support..."
echo "Access the UI at: http://localhost:5001"
echo "API docs at: http://localhost:5001/docs"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run with the CUDA-aware app if it exists, otherwise use regular app
if [[ -f "app_cuda.py" ]]; then
    echo "Using CUDA-optimized app..."
    uv run uvicorn app_cuda:app --host 127.0.0.1 --port 5001 --reload
else
    echo "Using standard app..."
    uv run uvicorn app:app --host 127.0.0.1 --port 5001 --reload
fi