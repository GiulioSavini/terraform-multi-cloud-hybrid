# =============================================================================
# Main Configuration - Stg Environment
# =============================================================================

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = "infrastructure"
    Repository  = "terraform-multi-cloud-hybrid"
  }
}

# =============================================================================
# Azure Resource Group (shared resource)
# =============================================================================

resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.azure_location
  tags     = local.common_tags
}
