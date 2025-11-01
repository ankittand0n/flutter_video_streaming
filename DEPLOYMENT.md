# Cloud Run Deployment

## Environment Variables Setup

Set environment variables in Cloud Run Console or via gcloud CLI.

### Backend Environment Variables

```bash
# Set via gcloud CLI
gcloud run services update backend \
  --region=asia-southeast1 \
  --update-env-vars="NODE_ENV=production,PORT=8080,DATABASE_URL=your-database-url,JWT_SECRET=your-jwt-secret"
```

**Or via Console:**
1. Go to: https://console.cloud.google.com/run/detail/asia-southeast1/backend
2. Click "EDIT & DEPLOY NEW REVISION"
3. Go to "Variables & Secrets" tab
4. Add environment variables:
   - `NODE_ENV` = `production`
   - `PORT` = `8080`
   - `DATABASE_URL` = (your Supabase connection string)
   - `JWT_SECRET` = (your secret key)

### Frontend Environment Variables

```bash
# Set via gcloud CLI
gcloud run services update frontend \
  --region=asia-southeast1 \
  --update-env-vars="API_BASE_URL=https://backend-xxxx.run.app,STORAGE_BASE_URL=https://storage.googleapis.com/namkeen-tv"
```

**Or via Console:**
1. Go to: https://console.cloud.google.com/run/detail/asia-southeast1/frontend
2. Click "EDIT & DEPLOY NEW REVISION"
3. Add environment variables:
   - `API_BASE_URL` = (your backend Cloud Run URL)
   - `STORAGE_BASE_URL` = `https://storage.googleapis.com/namkeen-tv`

## Automatic Deployment

Push to `master` branch triggers automatic deployment:
- Changes in `backend/` → triggers backend rebuild and deploy
- Changes in `frontend/` → triggers frontend rebuild and deploy

Cloud Build automatically:
1. Builds Docker image
2. Pushes to Artifact Registry
3. Deploys to Cloud Run (using existing env vars)

## Manual Commands

```bash
# View backend logs
gcloud run services logs read backend --region=asia-southeast1

# View frontend logs
gcloud run services logs read frontend --region=asia-southeast1

# Get service URLs
gcloud run services describe backend --region=asia-southeast1 --format='value(status.url)'
gcloud run services describe frontend --region=asia-southeast1 --format='value(status.url)'
```
