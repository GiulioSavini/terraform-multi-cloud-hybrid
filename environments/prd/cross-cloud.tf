# =============================================================================
# Cross-Cloud Resources - Prd Environment
# =============================================================================

module "cross_cloud_logging" {
  source                           = "../../modules/cross-cloud/logging"
  project                          = var.project
  environment                      = var.environment
  gcp_project_id                   = var.gcp_project_id
  azure_resource_group_name        = azurerm_resource_group.main.name
  azure_location                   = var.azure_location
  azure_log_analytics_workspace_id = module.azure_monitoring.log_analytics_workspace_id
  retention_days                   = 90
  tags                             = local.common_tags
}

module "cross_cloud_vpn" {
  source = "../../modules/cross-cloud/vpn"
  count  = var.enable_cross_cloud_vpn ? 1 : 0

  project                     = var.project
  environment                 = var.environment
  aws_vpn_gateway_id          = module.aws_network.vpn_gateway_id
  aws_vpc_cidr                = "10.0.0.0/16"
  azure_vpn_gateway_id        = module.azure_network.vpn_gateway_id
  azure_vpn_gateway_public_ip = module.azure_network.vpn_gateway_public_ip
  azure_vnet_cidr             = "10.1.0.0/16"
  azure_resource_group_name   = azurerm_resource_group.main.name
  azure_location              = var.azure_location
  shared_key                  = var.vpn_shared_key
  tags                        = local.common_tags
}
