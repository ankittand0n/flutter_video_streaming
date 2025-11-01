#!/bin/bash

# Setup Google Cloud Secrets from .env file
# Run this once to create secrets in Secret Manager

PROJECT_ID="trim-keep-475205-t7"

echo "=========================================="
echo "Creating Google Cloud Secrets"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
  echo "❌ Error: backend/.env file not found!"
  exit 1
fi

# Source the .env file
set -a
source backend/.env
set +a

echo "Creating secrets from backend/.env..."
echo ""

# Create DATABASE_URL secret
echo "1. Creating DATABASE_URL secret..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL not found in .env"
else
  echo -n "$DATABASE_URL" | gcloud secrets create DATABASE_URL \
    --data-file=- \
    --replication-policy="automatic" \
    --project=$PROJECT_ID 2>/dev/null || \
  echo -n "$DATABASE_URL" | gcloud secrets versions add DATABASE_URL \
    --data-file=- \
    --project=$PROJECT_ID
  echo "✅ DATABASE_URL created/updated"
fi
echo ""

# Create DIRECT_URL secret
echo "2. Creating DIRECT_URL secret..."
if [ -z "$DIRECT_URL" ]; then
  echo "❌ DIRECT_URL not found in .env"
else
  echo -n "$DIRECT_URL" | gcloud secrets create DIRECT_URL \
    --data-file=- \
    --replication-policy="automatic" \
    --project=$PROJECT_ID 2>/dev/null || \
  echo -n "$DIRECT_URL" | gcloud secrets versions add DIRECT_URL \
    --data-file=- \
    --project=$PROJECT_ID
  echo "✅ DIRECT_URL created/updated"
fi
echo ""

# Create JWT_SECRET secret
echo "3. Creating JWT_SECRET secret..."
if [ -z "$JWT_SECRET" ]; then
  echo "❌ JWT_SECRET not found in .env"
else
  echo -n "$JWT_SECRET" | gcloud secrets create JWT_SECRET \
    --data-file=- \
    --replication-policy="automatic" \
    --project=$PROJECT_ID 2>/dev/null || \
  echo -n "$JWT_SECRET" | gcloud secrets versions add JWT_SECRET \
    --data-file=- \
    --project=$PROJECT_ID
  echo "✅ JWT_SECRET created/updated"
fi
echo ""

# Grant Cloud Build access to secrets
echo "=========================================="
echo "Granting Cloud Build access to secrets"
echo "=========================================="
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
echo "Project Number: $PROJECT_NUMBER"
echo ""

for SECRET in DATABASE_URL DIRECT_URL JWT_SECRET; do
  echo "Granting access to $SECRET..."
  gcloud secrets add-iam-policy-binding $SECRET \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=$PROJECT_ID 2>/dev/null
  
  gcloud secrets add-iam-policy-binding $SECRET \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=$PROJECT_ID 2>/dev/null
done

echo ""
echo "=========================================="
echo "✅ Secrets setup complete!"
echo "=========================================="
echo ""
echo "Verify secrets:"
echo "  gcloud secrets list --project=$PROJECT_ID"
echo ""
echo "View secret value:"
echo "  gcloud secrets versions access latest --secret=JWT_SECRET"
echo ""
