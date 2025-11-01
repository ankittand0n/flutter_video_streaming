#!/bin/bash

# Setup Cloud Build triggers for automatic deployment
# This script creates triggers that deploy on push to master branch

PROJECT_ID="trim-keep-475205-t7"
REGION="asia-south2"
REPO_NAME="ankittand0n/flutter_video_streaming"

echo "=========================================="
echo "Setting up Cloud Build Triggers"
echo "=========================================="

# First, store your secrets in Secret Manager (run these once):
echo ""
echo "Step 1: Create secrets (if not already created):"
echo "-----------------------------------------------"
echo "Run these commands to store your secrets:"
echo ""
echo "echo -n 'your-database-url' | gcloud secrets create DATABASE_URL --data-file=- --replication-policy='automatic'"
echo "echo -n 'your-direct-url' | gcloud secrets create DIRECT_URL --data-file=- --replication-policy='automatic'"
echo "echo -n 'your-jwt-secret' | gcloud secrets create JWT_SECRET --data-file=- --replication-policy='automatic'"
echo ""

# Grant Cloud Build access to secrets
echo "Step 2: Grant Cloud Build access to secrets:"
echo "--------------------------------------------"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
echo "Project Number: $PROJECT_NUMBER"
echo ""
echo "gcloud secrets add-iam-policy-binding DATABASE_URL --member='serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com' --role='roles/secretmanager.secretAccessor'"
echo "gcloud secrets add-iam-policy-binding DIRECT_URL --member='serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com' --role='roles/secretmanager.secretAccessor'"
echo "gcloud secrets add-iam-policy-binding JWT_SECRET --member='serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com' --role='roles/secretmanager.secretAccessor'"
echo ""

# Grant Cloud Build permission to deploy to Cloud Run
echo "Step 3: Grant Cloud Build permissions:"
echo "--------------------------------------"
echo "gcloud projects add-iam-policy-binding $PROJECT_ID --member='serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com' --role='roles/run.admin'"
echo "gcloud projects add-iam-policy-binding $PROJECT_ID --member='serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com' --role='roles/iam.serviceAccountUser'"
echo ""

# Create triggers using public GitHub repo (no OAuth needed)
echo "Step 4: Create Cloud Build triggers for public repo:"
echo "----------------------------------------------------"
echo ""
echo "Creating Backend trigger..."
gcloud builds triggers create github \
  --name='deploy-backend' \
  --repo-name='flutter_video_streaming' \
  --repo-owner='ankittand0n' \
  --branch-pattern='^master$' \
  --build-config='cloudbuild-backend.yaml' \
  --region=$REGION \
  --included-files='backend/**'

echo ""
echo "Creating Frontend trigger..."
gcloud builds triggers create github \
  --name='deploy-frontend' \
  --repo-name='flutter_video_streaming' \
  --repo-owner='ankittand0n' \
  --branch-pattern='^master$' \
  --build-config='cloudbuild-frontend.yaml' \
  --region=$REGION \
  --included-files='frontend/**'
echo ""

echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Create and configure secrets as shown in Step 1"
echo "2. Grant permissions as shown in Steps 2 & 3"
echo "3. Connect GitHub repository as shown in Step 4"
echo "4. Create triggers using commands in Step 5"
echo ""
echo "After setup, every push to 'master' branch will:"
echo "  - Build Docker images"
echo "  - Push to Artifact Registry"
echo "  - Automatically deploy to Cloud Run"
echo ""
echo "You can also trigger manually:"
echo "  gcloud builds triggers run deploy-backend --branch=master"
echo "  gcloud builds triggers run deploy-frontend --branch=master"
echo ""
