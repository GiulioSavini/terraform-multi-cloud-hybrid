# =============================================================================
# Cross-Cloud Resources - Dev Environment
# =============================================================================

module "cross_cloud_logging" {
  source = "../../modules/cross-cloud/logging"

  project                          = var.project
  environment                      = var.environment
  gcp_project_id                   = var.gcp_project_id
  azure_resource_group_name        = azurerm_resource_group.main.name
  azure_location                   = var.azure_location
  azure_log_analytics_workspace_id = module.azure_monitoring.log_analytics_workspace_id
  retention_days                   = 30
  tags                             = local.common_tags
}
