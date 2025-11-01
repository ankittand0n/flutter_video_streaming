#!/bin/sh
set -e

# Default values
API_BASE_URL=${API_BASE_URL:-"http://localhost:3000"}
STORAGE_BASE_URL=${STORAGE_BASE_URL:-"https://storage.googleapis.com/namkeen-tv"}

# Create config.js with environment variables
cat > /usr/share/nginx/html/config.js <<CONFIGEOF
window.ENV = {
  apiBaseUrl: "${API_BASE_URL}",
  storageBaseUrl: "${STORAGE_BASE_URL}"
};
CONFIGEOF

echo "========================================="
echo "Namkeen TV Frontend Starting..."
echo "========================================="
echo "Config generated:"
cat /usr/share/nginx/html/config.js
echo "========================================="

# Start nginx
exec nginx -g 'daemon off;'
