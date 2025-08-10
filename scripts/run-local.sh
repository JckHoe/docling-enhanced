#!/bin/bash

# Run the application locally with UV
cd "$(dirname "$0")/.."

# Install dependencies if needed
uv sync

# Run the application
uv run uvicorn app:app --host 0.0.0.0 --port 5001 --reload