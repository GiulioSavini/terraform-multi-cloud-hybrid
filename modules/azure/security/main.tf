locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "azure/security" })
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                       = "${replace(local.name_prefix, "-", "")}kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = var.environment == "prd"
  soft_delete_retention_days = 30
  enable_rbac_authorization  = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Diagnostic Settings for NSG Flow Logs
# ------------------------------------------------------------------------------
resource "azurerm_storage_account" "security_logs" {
  name                      = "${replace(local.name_prefix, "-", "")}seclogs"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = false
  https_traffic_only        = true

  blob_properties {
    delete_retention_policy {
      days = 30
    }
  }

  tags = local.common_tags
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}
