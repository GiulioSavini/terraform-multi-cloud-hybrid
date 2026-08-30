# ==============================================================================
# Deployment: dev
#
# Binds the landing-zone application to one environment. Everything that varies
# between environments lives here; everything that does not lives in
# applications/landing-zone.
# ==============================================================================

module "landing_zone" {
  source = "../../applications/landing-zone"

  landing_zone = "hybrid"
  environment  = var.environment
  clouds       = ["aws"]

  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification

  azure_location  = "westeurope"
  azure_tenant_id = var.azure_tenant_id
  gcp_project_id  = var.gcp_project_id
  gcp_region      = var.gcp_region

  capacity = { min = 2, desired = 2, max = 4 }

  domain_name         = var.domain_name
  alarm_email         = var.alarm_email
  ssl_certificate_arn = var.ssl_certificate_arn
  retention_days      = 90

  enable_cross_cloud_connectivity = false
  cross_cloud_shared_key          = var.cross_cloud_shared_key
  enable_central_logging          = false
  flow_log_storage_account_id     = var.flow_log_storage_account_id
}
