import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from docling_serve.app import app

# The app is already configured in docling_serve.app
# This file just imports it for easier access