provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {
    key_vault {
      # Soft-deleted vaults block redeployment under the same name. Purging on
      # destroy is right for non-production and wrong for production, so the
      # value tracks the environment rather than being hardcoded.
      purge_soft_delete_on_destroy = var.environment != "prd"
    }
  }
  subscription_id = var.azure_subscription_id
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
