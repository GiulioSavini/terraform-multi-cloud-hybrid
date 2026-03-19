# =============================================================================
# GCP Resources - Stg Environment
# =============================================================================

module "gcp_network" {
  source         = "../../modules/gcp/network"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
  labels         = local.common_tags
}

module "gcp_security" {
  source         = "../../modules/gcp/security"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.common_tags
}

module "gcp_compute" {
  source                = "../../modules/gcp/compute"
  project               = var.project
  environment           = var.environment
  gcp_project_id        = var.gcp_project_id
  region                = var.gcp_region
  network_self_link     = module.gcp_network.network_self_link
  subnet_self_link      = module.gcp_network.web_subnet_self_link
  machine_type          = "e2-small" # Stg: medium
  min_replicas          = 2
  max_replicas          = 4
  service_account_email = module.gcp_security.compute_service_account_email
  labels                = local.common_tags
}

module "gcp_monitoring" {
  source             = "../../modules/gcp/monitoring"
  project            = var.project
  environment        = var.environment
  gcp_project_id     = var.gcp_project_id
  notification_email = var.alarm_email
  lb_ip_address      = module.gcp_compute.lb_ip_address
}

module "gcp_dns" {
  source         = "../../modules/gcp/dns"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  domain_name    = var.domain_name
  lb_ip_address  = module.gcp_compute.lb_ip_address
}
