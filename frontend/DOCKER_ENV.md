# Docker Environment Configuration

The Flutter web app supports runtime configuration through environment variables injected at container startup.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API endpoint | `http://localhost:3000/api` |
| `STORAGE_BASE_URL` | Google Cloud Storage bucket URL | `https://storage.googleapis.com/namkeen-tv` |

## Usage

### Local Development

```bash
# Build the image
docker build -t namkeen-tv-frontend .

# Run with default config
docker run -p 8080:8080 namkeen-tv-frontend

# Run with custom API endpoint
docker run -p 8080:8080 \
  -e API_BASE_URL="https://backend-1040805906877.asia-south2.run.app/api" \
  -e STORAGE_BASE_URL="https://storage.googleapis.com/namkeen-tv" \
  namkeen-tv-frontend
```

### Google Cloud Run

```bash
# Deploy with environment variables
gcloud run deploy namkeen-tv-frontend \
  --image gcr.io/YOUR_PROJECT/namkeen-tv-frontend \
  --platform managed \
  --region asia-south2 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars API_BASE_URL="https://backend-1040805906877.asia-south2.run.app/api" \
  --set-env-vars STORAGE_BASE_URL="https://storage.googleapis.com/namkeen-tv"
```

### Docker Compose

```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "8080:8080"
    environment:
      - API_BASE_URL=http://backend:3000/api
      - STORAGE_BASE_URL=https://storage.googleapis.com/namkeen-tv
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/namkeen
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: namkeen-tv-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: namkeen-tv-frontend
  template:
    metadata:
      labels:
        app: namkeen-tv-frontend
    spec:
      containers:
      - name: frontend
        image: gcr.io/YOUR_PROJECT/namkeen-tv-frontend
        ports:
        - containerPort: 8080
        env:
        - name: API_BASE_URL
          value: "https://backend-1040805906877.asia-south2.run.app/api"
        - name: STORAGE_BASE_URL
          value: "https://storage.googleapis.com/namkeen-tv"
```

## How It Works

1. **Startup Script**: When the container starts, `/docker-entrypoint.sh` reads environment variables
2. **Config Generation**: Creates `/usr/share/nginx/html/config.js` with runtime values
3. **HTML Injection**: `web/index.html` loads `config.js` before Flutter app
4. **Dart Access**: `AppConfig` class reads values from `window.ENV`

### Generated config.js

```javascript
window.ENV = {
  apiBaseUrl: "https://backend-1040805906877.asia-south2.run.app/api",
  storageBaseUrl: "https://storage.googleapis.com/namkeen-tv"
};
```

## Testing

### Verify configuration in browser console

```javascript
// Open browser console (F12)
console.log(window.ENV);
// Should show: { apiBaseUrl: "...", storageBaseUrl: "..." }
```

### Check from Flutter app

In your `main.dart`, add:

```dart
import 'config/app_config.dart';

void main() {
  AppConfig.printConfig(); // Prints current configuration
  runApp(MyApp());
}
```

## Troubleshooting

### Config not loading

1. Check if `config.js` exists:
```bash
docker exec -it <container_id> cat /usr/share/nginx/html/config.js
```

2. Check browser Network tab for 404 errors on `config.js`

### Wrong values

1. Verify environment variables are set:
```bash
docker exec -it <container_id> env | grep -E 'API_BASE_URL|STORAGE_BASE_URL'
```

2. Check Docker logs:
```bash
docker logs <container_id>
# Should show: "Config generated: window.ENV = { ... }"
```

### Fallback values being used

The app will use fallback values if:
- `config.js` fails to load
- `window.ENV` is undefined
- JavaScript error occurs

Default fallbacks:
- API: `https://backend-1040805906877.asia-south2.run.app/api`
- Storage: `https://storage.googleapis.com/namkeen-tv`

## Build and Deploy Script

```bash
#!/bin/bash

# Build
docker build -t gcr.io/YOUR_PROJECT/namkeen-tv-frontend:latest ./frontend

# Push to GCR
docker push gcr.io/YOUR_PROJECT/namkeen-tv-frontend:latest

# Deploy to Cloud Run
gcloud run deploy namkeen-tv-frontend \
  --image gcr.io/YOUR_PROJECT/namkeen-tv-frontend:latest \
  --platform managed \
  --region asia-south2 \
  --allow-unauthenticated \
  --port 8080 \
  --min-instances 0 \
  --max-instances 10 \
  --memory 256Mi \
  --cpu 1 \
  --set-env-vars API_BASE_URL="https://YOUR-BACKEND-URL/api" \
  --set-env-vars STORAGE_BASE_URL="https://storage.googleapis.com/namkeen-tv"
```
