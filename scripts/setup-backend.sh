#!/usr/bin/env bash
# =============================================================================
# setup-backend.sh
# Creates remote state backends for all cloud providers
# Usage: ./scripts/setup-backend.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
PROJECT="hybrid-landing-zone"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=============================================="
echo "  Setting up Terraform backends for: $ENV"
echo "=============================================="

# --- AWS: S3 + DynamoDB ---
echo ""
echo -e "${YELLOW}--- AWS Backend (S3 + DynamoDB) ---${NC}"

AWS_REGION=$(aws configure get region 2>/dev/null || echo "eu-west-1")
BUCKET_NAME="${PROJECT}-tfstate-${ENV}"
DYNAMODB_TABLE="${PROJECT}-tflock-${ENV}"

echo "Creating S3 bucket: $BUCKET_NAME"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo -e "${GREEN}Bucket already exists${NC}"
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"

  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
      "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]
    }'

  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

  echo -e "${GREEN}S3 bucket created with versioning + encryption${NC}"
fi

echo "Creating DynamoDB table: $DYNAMODB_TABLE"
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" &>/dev/null; then
  echo -e "${GREEN}DynamoDB table already exists${NC}"
else
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"

  echo -e "${GREEN}DynamoDB lock table created${NC}"
fi

# --- Azure: Storage Account + Container ---
echo ""
echo -e "${YELLOW}--- Azure Backend (Blob Storage) ---${NC}"

if command -v az &>/dev/null && az account show &>/dev/null 2>&1; then
  AZ_RG="${PROJECT}-tfstate-rg"
  AZ_SA=$(echo "${PROJECT}${ENV}tfstate" | tr -d '-' | cut -c1-24)
  AZ_CONTAINER="tfstate"
  AZ_LOCATION="westeurope"

  echo "Creating Resource Group: $AZ_RG"
  az group create --name "$AZ_RG" --location "$AZ_LOCATION" --output none 2>/dev/null || true

  echo "Creating Storage Account: $AZ_SA"
  az storage account create \
    --name "$AZ_SA" \
    --resource-group "$AZ_RG" \
    --location "$AZ_LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --output none 2>/dev/null || echo -e "${GREEN}Storage account already exists${NC}"

  echo "Creating Blob Container: $AZ_CONTAINER"
  az storage container create \
    --name "$AZ_CONTAINER" \
    --account-name "$AZ_SA" \
    --auth-mode login \
    --output none 2>/dev/null || echo -e "${GREEN}Container already exists${NC}"

  echo -e "${GREEN}Azure backend ready${NC}"
else
  echo -e "${RED}Azure CLI not authenticated, skipping${NC}"
fi

# --- GCP: GCS Bucket ---
echo ""
echo -e "${YELLOW}--- GCP Backend (GCS) ---${NC}"

if command -v gcloud &>/dev/null; then
  GCP_PROJECT=$(gcloud config get-value project 2>/dev/null)
  GCS_BUCKET="${PROJECT}-tfstate-${ENV}-${GCP_PROJECT}"
  GCS_LOCATION="EU"

  echo "Creating GCS bucket: $GCS_BUCKET"
  if gsutil ls "gs://$GCS_BUCKET" &>/dev/null; then
    echo -e "${GREEN}GCS bucket already exists${NC}"
  else
    gsutil mb -p "$GCP_PROJECT" -l "$GCS_LOCATION" "gs://$GCS_BUCKET"
    gsutil versioning set on "gs://$GCS_BUCKET"
    gsutil ubla set on "gs://$GCS_BUCKET"
    echo -e "${GREEN}GCS bucket created with versioning${NC}"
  fi
else
  echo -e "${RED}gcloud not found, skipping${NC}"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}All backends configured for: $ENV${NC}"
echo "=============================================="
echo ""
echo "You can now run:"
echo "  cd environments/$ENV"
echo "  terraform init"
