# ==============================================================================
# Application: landing zone
#
# Composition root. This is the only place where bounded contexts are wired to
# one another, and the only place that knows the order they depend in:
#
#   networking -> access-control -> workload-hosting -> service-discovery
#                                                    -> observability
#
# Contexts talk to each other exclusively through the contracts published in
# their outputs.tf. If a wiring below reaches into a provider adapter, that is
# a defect in this file, not a shortcut.
# ==============================================================================

locals {
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  # Shared placement resource. The resource group is not owned by any single
  # context — every Azure adapter is placed into it — so it belongs here.
  azure_resource_group_name = local.azure_enabled ? azurerm_resource_group.main[0].name : ""
}

# --- Shared kernel ------------------------------------------------------------

module "tags" {
  for_each = toset(["networking", "access-control", "workload-hosting", "service-discovery", "observability"])
  source   = "../../platform/tagging"

  landing_zone        = var.landing_zone
  environment         = var.environment
  context             = each.key
  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification
}

module "naming" {
  source = "../../platform/naming"

  landing_zone = var.landing_zone
  environment  = var.environment
  context      = "platform"
}

resource "azurerm_resource_group" "main" {
  count = local.azure_enabled ? 1 : 0

  name     = "${module.naming.prefix}-rg"
  location = var.azure_location
  tags     = module.tags["networking"].tags
}

# --- Bounded contexts ---------------------------------------------------------

module "networking" {
  source = "../../domains/networking"

  landing_zone  = var.landing_zone
  environment   = var.environment
  clouds        = var.clouds
  address_space = var.address_space

  placement = {
    aws = { availability_zones = var.aws_availability_zones }
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = local.azure_resource_group_name
    } : null
    gcp = local.gcp_enabled ? {
      project_id = var.gcp_project_id
      region     = var.gcp_region
    } : null
  }

  enable_cross_cloud_connectivity = var.enable_cross_cloud_connectivity
  cross_cloud_shared_key          = var.cross_cloud_shared_key
  flow_log_storage_account_id     = var.flow_log_storage_account_id

  tags   = module.tags["networking"].tags
  labels = module.tags["networking"].labels
}

module "access_control" {
  source = "../../domains/access-control"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = local.azure_resource_group_name
      tenant_id           = var.azure_tenant_id
    } : null
    gcp = local.gcp_enabled ? { project_id = var.gcp_project_id } : null
  }

  alb_ingress_cidrs = var.alb_ingress_cidrs

  tags   = module.tags["access-control"].tags
  labels = module.tags["access-control"].labels
}

module "workload_hosting" {
  source = "../../domains/workload-hosting"

  landing_zone   = var.landing_zone
  environment    = var.environment
  clouds         = var.clouds
  networks       = module.networking.networks
  gcp_self_links = local.gcp_enabled ? module.networking.gcp_self_links : null

  workload_identity = module.access_control.workload_identity
  perimeter         = module.access_control.perimeter

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = local.azure_resource_group_name
    } : null
    gcp = local.gcp_enabled ? {
      project_id = var.gcp_project_id
      region     = var.gcp_region
    } : null
  }

  capacity            = var.capacity
  instance_size       = var.instance_size
  aws_ami_id          = var.aws_ami_id
  ssl_certificate_arn = var.ssl_certificate_arn
  domain_name         = var.domain_name

  tags   = module.tags["workload-hosting"].tags
  labels = module.tags["workload-hosting"].labels
}

module "service_discovery" {
  source = "../../domains/service-discovery"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  domain_name  = var.domain_name

  endpoints = module.workload_hosting.endpoints
  networks  = module.networking.networks

  placement = {
    azure = local.azure_enabled ? { resource_group_name = local.azure_resource_group_name } : null
    gcp   = local.gcp_enabled ? { project_id = var.gcp_project_id } : null
  }

  create_public_zone = var.create_public_zone

  tags = module.tags["service-discovery"].tags
}

module "observability" {
  source = "../../domains/observability"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds

  workload_refs = module.workload_hosting.workload_refs
  endpoints     = module.workload_hosting.endpoints

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = local.azure_resource_group_name
    } : null
    gcp = local.gcp_enabled ? { project_id = var.gcp_project_id } : null
  }

  alarm_email            = var.alarm_email
  retention_days         = var.retention_days
  enable_central_logging = var.enable_central_logging

  tags = module.tags["observability"].tags
}

# --- Compliance ---------------------------------------------------------------

module "controls" {
  source = "../../compliance/controls"
}
