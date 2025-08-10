import sys
import os
import torch
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

USE_GPU = os.environ.get('DOCLING_OCR_USE_GPU', 'false').lower() == 'true'
if USE_GPU:
    if torch.cuda.is_available():
        logger.info(f"CUDA is available. Using GPU: {torch.cuda.get_device_name(0)}")
        logger.info(f"CUDA version: {torch.version.cuda}")
        logger.info(f"PyTorch version: {torch.__version__}")
    else:
        logger.warning("DOCLING_OCR_USE_GPU is set to true but CUDA is not available. Falling back to CPU.")
        USE_GPU = False
else:
    logger.info("Running in CPU mode. Set DOCLING_OCR_USE_GPU=true to enable GPU support.")

if USE_GPU:
    os.environ['EASYOCR_USE_GPU'] = 'True'
else:
    os.environ['EASYOCR_USE_GPU'] = 'False'

from docling_serve.app import create_app

app = create_app()

@app.on_event("startup")
async def startup_event():
    logger.info(f"Docling Enhanced started with GPU support: {USE_GPU}")
    if USE_GPU:
        logger.info(f"GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB")
        logger.info(f"CUDA Device: {torch.cuda.current_device()}")
