# =============================================================================
# Azure-Only Example
# Deploys only the Azure landing zone: VNet + VMSS + LB + NGINX + Monitoring
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="azure_subscription_id=YOUR_SUB_ID" -var="azure_tenant_id=YOUR_TENANT"
#
# Estimated cost: ~$40/month
# Deploy time: ~10 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

variable "azure_subscription_id" { type = string }
variable "azure_tenant_id" { type = string }
variable "location" { type = string; default = "westeurope" }

locals {
  project     = "azure-example"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment, ManagedBy = "terraform" }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.location
  tags     = local.tags
}

# --- Network: VNet + 3 subnets + NSGs ---
module "network" {
  source = "../../modules/azure/network"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_cidr           = "10.1.0.0/16"
  tags                = local.tags
}

# --- Compute: VMSS + Azure LB + NGINX ---
module "compute" {
  source = "../../modules/azure/compute"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  app_subnet_id       = module.network.app_subnet_id
  web_subnet_id       = module.network.web_subnet_id
  vm_sku              = "Standard_B1s"
  instance_count      = 1
  tags                = local.tags
}

# --- Security: Key Vault + Managed Identity ---
module "security" {
  source = "../../modules/azure/security"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tenant_id           = var.azure_tenant_id
  tags                = local.tags
}

# --- Monitoring: Log Analytics + App Insights ---
module "monitoring" {
  source = "../../modules/azure/monitoring"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vmss_id             = module.compute.vmss_id
  tags                = local.tags
}

output "lb_public_ip" {
  value = module.compute.lb_public_ip
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}
