#!/bin/bash

# Build and push backend Docker image to Google Artifact Registry
set -e

# Configuration
PROJECT_ID="trim-keep-475205-t7"
REGION="asia-south2"
REPOSITORY="namkeen-tv"
IMAGE_NAME="backend"
TAG="${1:-latest}"

# Full image path
FULL_IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "========================================="
echo "Building Backend Docker Image"
echo "========================================="
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Repository: $REPOSITORY"
echo "Image: $IMAGE_NAME"
echo "Tag: $TAG"
echo "Full Path: $FULL_IMAGE_PATH"
echo "========================================="

# Navigate to backend directory
cd backend

# Build the Docker image
echo ""
echo "Step 1: Building Docker image..."
docker build -t ${IMAGE_NAME}:${TAG} -t ${FULL_IMAGE_PATH} .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Docker image built successfully!"

# Configure Docker to use gcloud as credential helper
echo ""
echo "Step 2: Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Push to Artifact Registry
echo ""
echo "Step 3: Pushing image to Artifact Registry..."
docker push ${FULL_IMAGE_PATH}

if [ $? -ne 0 ]; then
    echo "❌ Docker push failed!"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ Backend image successfully pushed!"
echo "========================================="
echo ""
echo "Image URL: ${FULL_IMAGE_PATH}"
echo ""
echo "To pull this image:"
echo "  docker pull ${FULL_IMAGE_PATH}"
echo ""
echo "To deploy to Cloud Run:"
echo "  gcloud run deploy backend \\"
echo "    --image ${FULL_IMAGE_PATH} \\"
echo "    --platform managed \\"
echo "    --region ${REGION} \\"
echo "    --allow-unauthenticated \\"
echo "    --port 8080 \\"
echo "    --set-env-vars DATABASE_URL=\$DATABASE_URL,JWT_SECRET=\$JWT_SECRET,DIRECT_URL=\$DIRECT_URL"
echo ""
echo "========================================="
