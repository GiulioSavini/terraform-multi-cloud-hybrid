# =============================================================================
# Azure Resources - Prd Environment
# =============================================================================

module "azure_network" {
  source              = "../../modules/azure/network"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vnet_cidr           = "10.1.0.0/16"
  enable_vpn_gateway  = var.enable_cross_cloud_vpn
  tags                = local.common_tags
}

module "azure_compute" {
  source              = "../../modules/azure/compute"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  app_subnet_id       = module.azure_network.app_subnet_id
  web_subnet_id       = module.azure_network.web_subnet_id
  vm_sku              = "Standard_D2s_v5" # Prd: larger
  instance_count      = 3
  min_instances       = 3
  max_instances       = 10
  tags                = local.common_tags
}

module "azure_security" {
  source              = "../../modules/azure/security"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  tenant_id           = var.azure_tenant_id
  tags                = local.common_tags
}

module "azure_monitoring" {
  source              = "../../modules/azure/monitoring"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vmss_id             = module.azure_compute.vmss_id
  alarm_email         = var.alarm_email
  tags                = local.common_tags
}

module "azure_dns" {
  source              = "../../modules/azure/dns"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.azure_network.vnet_id
  tags                = local.common_tags
}
