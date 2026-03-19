# =============================================================================
# GCP-Only Example
# Deploys only the GCP landing zone: VPC + MIG + HTTPS LB + NGINX + Monitoring
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="gcp_project_id=YOUR_PROJECT"
#
# Estimated cost: ~$30/month (e2-micro free tier eligible)
# Deploy time: ~5 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

variable "gcp_project_id" { type = string }
variable "gcp_region" { type = string; default = "europe-west1" }

locals {
  project     = "gcp-example"
  environment = "dev"
  labels      = { project = local.project, environment = local.environment, managed_by = "terraform" }
}

# --- Network: VPC + subnets + Cloud NAT ---
module "network" {
  source = "../../modules/gcp/network"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
  labels         = local.labels
}

# --- Security: Service account + Cloud Armor ---
module "security" {
  source = "../../modules/gcp/security"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.labels
}

# --- Compute: MIG + HTTPS LB + NGINX ---
module "compute" {
  source = "../../modules/gcp/compute"

  project               = local.project
  environment           = local.environment
  gcp_project_id        = var.gcp_project_id
  region                = var.gcp_region
  network_self_link     = module.network.network_self_link
  subnet_self_link      = module.network.web_subnet_self_link
  machine_type          = "e2-micro"
  min_replicas          = 1
  max_replicas          = 2
  service_account_email = module.security.compute_service_account_email
  labels                = local.labels
}

# --- Monitoring: Alerts + Uptime checks ---
module "monitoring" {
  source = "../../modules/gcp/monitoring"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  lb_ip_address  = module.compute.lb_ip_address
}

output "lb_ip" {
  value = "https://${module.compute.lb_ip_address}/health"
}
