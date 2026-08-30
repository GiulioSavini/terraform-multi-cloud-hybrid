# ------------------------------------------------------------------------------
# Bounded context: observability
#
# Owns detection: metrics, alarms, log retention and, optionally, the
# cross-cloud log archive. It attaches to handles published by
# workload-hosting and never reads compute resources directly.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  # The central archive fans Azure and GCP logs into one place. Without both,
  # there is nothing to centralise and the module would build an empty shell.
  central_logging_possible = local.azure_enabled && local.gcp_enabled
  central_logging_enabled  = var.enable_central_logging && local.central_logging_possible
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.workload_refs)))) == 0
      error_message = "Every cloud in clouds must have an entry in workload_refs. There is nothing to alarm on otherwise."
    }
    precondition {
      condition     = !var.enable_central_logging || local.central_logging_possible
      error_message = "enable_central_logging requires both azure and gcp in clouds; the archive has no other sources in this landing zone."
    }
    precondition {
      condition     = var.environment != "prd" || var.retention_days >= 365
      error_message = "retention_days must be at least 365 in prd. ISO 27001 A.8.15 and NIS2 expect a year of retention for production systems."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project        = var.landing_zone
  environment    = var.environment
  alb_arn_suffix = var.workload_refs["aws"].alb_arn_suffix
  asg_name       = var.workload_refs["aws"].asg_name
  alarm_email    = var.alarm_email
  kms_key_arn    = var.kms_key_arn
  tags           = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project             = var.landing_zone
  environment         = var.environment
  resource_group_name = var.placement.azure.resource_group_name
  location            = var.placement.azure.location
  vmss_id             = var.workload_refs["azure"].vmss_id
  alarm_email         = var.alarm_email
  tags                = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project            = var.landing_zone
  environment        = var.environment
  gcp_project_id     = var.placement.gcp.project_id
  notification_email = var.alarm_email
  lb_ip_address      = try(var.endpoints["gcp"].address, "")

  depends_on = [terraform_data.guards]
}

module "cross_cloud" {
  count  = local.central_logging_enabled ? 1 : 0
  source = "./cross-cloud"

  project     = var.landing_zone
  environment = var.environment

  gcp_project_id                   = var.placement.gcp.project_id
  azure_log_analytics_workspace_id = module.azure[0].log_analytics_workspace_id

  retention_days = var.retention_days
  tags           = var.tags
}
