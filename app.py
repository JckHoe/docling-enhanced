import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from docling_serve.app import create_app

# Create the FastAPI app instance
app = create_app()