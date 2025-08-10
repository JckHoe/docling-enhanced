import mimetypes
import logging
from pathlib import Path
from typing import Optional, Tuple

logger = logging.getLogger(__name__)

class MimeDetector:
    """Enhanced MIME type detection for Docling Serve"""
    
    def __init__(self):
        # Initialize mimetypes
        mimetypes.init()
        
        # Add custom mappings for formats that might not be in standard mimetypes
        self.custom_types = {
            '.webp': 'image/webp',
            '.ico': 'image/x-icon',
            '.svg': 'image/svg+xml',
            '.tif': 'image/tiff',
            '.tiff': 'image/tiff',
            '.bmp': 'image/bmp',
            '.wav': 'audio/wav',
            '.mp3': 'audio/mpeg',
        }
        
        # Extension mapping for when we need to generate filenames
        self.mime_to_extension = {
            'image/jpeg': '.jpg',
            'image/png': '.png',
            'image/gif': '.gif',
            'image/tiff': '.tiff',
            'image/bmp': '.bmp',
            'image/webp': '.webp',
            'image/svg+xml': '.svg',
            'image/x-icon': '.ico',
            'application/pdf': '.pdf',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
            'application/vnd.openxmlformats-officedocument.presentationml.presentation': '.pptx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
            'text/html': '.html',
            'text/plain': '.txt',
            'text/markdown': '.md',
            'audio/wav': '.wav',
            'audio/mpeg': '.mp3',
            'audio/x-wav': '.wav',
        }
        
        # Supported image formats by Docling
        self.supported_image_mimes = {
            'image/jpeg', 'image/png', 'image/gif', 'image/tiff',
            'image/bmp', 'image/webp', 'image/svg+xml', 'image/x-icon'
        }
        
    def detect_from_content(self, content: bytes) -> Optional[str]:
        """Detect MIME type from file content using magic bytes"""
        # Check common image format signatures
        if content.startswith(b'\xff\xd8\xff'):
            return 'image/jpeg'
        elif content.startswith(b'\x89PNG\r\n\x1a\n'):
            return 'image/png'
        elif content.startswith(b'GIF87a') or content.startswith(b'GIF89a'):
            return 'image/gif'
        elif content.startswith(b'BM'):
            return 'image/bmp'
        elif content.startswith(b'II\x2a\x00') or content.startswith(b'MM\x00\x2a'):
            return 'image/tiff'
        elif content.startswith(b'RIFF') and b'WEBP' in content[:12]:
            return 'image/webp'
        elif content.startswith(b'%PDF'):
            return 'application/pdf'
        elif content.startswith(b'PK\x03\x04'):
            # This could be DOCX, PPTX, XLSX or other zip-based formats
            # We'll need to rely on filename for these
            return None
        elif content.startswith(b'<svg') or b'<svg' in content[:1000]:
            return 'image/svg+xml'
        elif content.startswith(b'\x00\x00\x01\x00'):
            return 'image/x-icon'
        
        return None
    
    def detect_from_filename(self, filename: str) -> Optional[str]:
        """Detect MIME type from filename"""
        if not filename:
            return None
            
        path = Path(filename)
        ext = path.suffix.lower()
        
        # Check custom types first
        if ext in self.custom_types:
            return self.custom_types[ext]
        
        # Use standard mimetypes
        mime_type, _ = mimetypes.guess_type(filename)
        return mime_type
    
    def detect(self, filename: Optional[str], content: Optional[bytes]) -> Tuple[Optional[str], str]:
        """
        Detect MIME type using both filename and content.
        Returns (mime_type, detection_method)
        """
        content_mime = None
        filename_mime = None
        
        if content:
            content_mime = self.detect_from_content(content)
            
        if filename:
            filename_mime = self.detect_from_filename(filename)
        
        # Prefer content-based detection for reliability
        if content_mime:
            logger.debug(f"Detected MIME from content: {content_mime}")
            return content_mime, "content"
        elif filename_mime:
            logger.debug(f"Detected MIME from filename: {filename_mime}")
            return filename_mime, "filename"
        else:
            logger.warning("Could not detect MIME type")
            return None, "none"
    
    def get_extension_from_mime(self, mime_type: str) -> str:
        """Get file extension from MIME type"""
        return self.mime_to_extension.get(mime_type, '')
    
    def is_supported_image(self, mime_type: str) -> bool:
        """Check if the MIME type is a supported image format"""
        return mime_type in self.supported_image_mimes
    
    def generate_filename(self, mime_type: str, index: int = 0) -> str:
        """Generate a filename based on MIME type"""
        ext = self.get_extension_from_mime(mime_type)
        if not ext:
            ext = '.bin'  # fallback for unknown types
            
        suffix = f"_{index}" if index > 0 else ""
        return f"file{suffix}{ext}"