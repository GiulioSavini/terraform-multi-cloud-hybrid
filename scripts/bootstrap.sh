#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh
# One-command setup: validates prerequisites, creates backends, generates tfvars
# Usage: ./scripts/bootstrap.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV=${1:-dev}

cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   Multi-Cloud Hybrid Landing Zone Bootstrap  ║"
echo "║   Environment: $ENV                            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Validate prerequisites
echo "📋 Step 1/5: Validating prerequisites..."
echo "----------------------------------------------"
bash "$SCRIPT_DIR/validate-prereqs.sh" || {
  echo ""
  echo "Fix the issues above and re-run this script."
  exit 1
}

# Step 2: Setup pre-commit hooks
echo ""
echo "🪝 Step 2/5: Setting up pre-commit hooks..."
echo "----------------------------------------------"
if command -v pre-commit &>/dev/null; then
  pre-commit install
  echo "Pre-commit hooks installed."
else
  echo "pre-commit not found, skipping. Install with: pip install pre-commit"
fi

# Step 3: Create remote backends
echo ""
echo "🗄️  Step 3/5: Creating remote state backends..."
echo "----------------------------------------------"
bash "$SCRIPT_DIR/setup-backend.sh" "$ENV"

# Step 4: Auto-discover variables
echo ""
echo "🔍 Step 4/5: Auto-discovering cloud variables..."
echo "----------------------------------------------"
bash "$SCRIPT_DIR/get-variables.sh" "$ENV"

# Step 5: Initialize Terraform
echo ""
echo "🚀 Step 5/5: Initializing Terraform..."
echo "----------------------------------------------"
cd "environments/$ENV"
terraform init -upgrade

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Bootstrap complete!                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Review: cat environments/$ENV/terraform.tfvars"
echo "  2. Plan:   make plan ENV=$ENV"
echo "  3. Apply:  make apply ENV=$ENV"
echo ""
echo "Useful commands:"
echo "  make help          # Show all available commands"
echo "  make cost ENV=$ENV # Estimate costs with Infracost"
echo "  make lint          # Run TFLint"
echo "  make security      # Run tfsec + checkov"
