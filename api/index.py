import os
import sys

# Add parent directory to path
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

# Import and create app
from app import create_app

# WSGI middleware to fix path for Vercel serverless
class VercelPathMiddleware:
    """
    Middleware to fix PATH_INFO for Vercel Python serverless functions.
    
    When Vercel routes requests to /api/index.py, the original path is lost.
    This middleware restores it from Vercel's headers or SCRIPT_NAME.
    """
    def __init__(self, app):
        self.app = app
    
    def __call__(self, environ, start_response):
        current_path = environ.get('PATH_INFO', '/')
        script_name = environ.get('SCRIPT_NAME', '')
        
        # Case 1: SCRIPT_NAME has the real path (most common in Vercel)
        if script_name and script_name not in ['', '/', '/api', '/api/index', '/api/index.py']:
            # SCRIPT_NAME contains the original path, move it to PATH_INFO
            environ['PATH_INFO'] = script_name
            environ['SCRIPT_NAME'] = ''
        
        # Case 2: PATH_INFO is the handler path, check headers for original
        elif current_path in ['/api/index.py', '/api/index', '/index.py', '/index', '/']:
            # Try various Vercel headers
            for header in ['HTTP_X_INVOKE_PATH', 'HTTP_X_MATCHED_PATH', 'HTTP_X_ORIGINAL_URL', 'RAW_URI', 'REQUEST_URI']:
                value = environ.get(header, '')
                if value and value not in ['/api/index.py', '/api/index', '/index.py', '/index', '/', '']:
                    # Extract just the path part
                    if header in ['HTTP_X_ORIGINAL_URL', 'RAW_URI', 'REQUEST_URI']:
                        value = value.split('?')[0]  # Remove query string
                    if value.startswith('/'):
                        environ['PATH_INFO'] = value
                        break
        
        return self.app(environ, start_response)


# Create the Flask app
flask_app = create_app()

# Wrap with middleware for Vercel
# Vercel requires the WSGI app to be named 'app'
app = VercelPathMiddleware(flask_app)
