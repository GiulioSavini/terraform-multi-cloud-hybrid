# ------------------------------------------------------------------------------
# Bounded context: service-discovery
#
# Owns how a workload is found: public DNS records and private zones. It reads
# addresses from the workload-hosting contract and never inspects compute.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.endpoints)))) == 0
      error_message = "Every cloud in clouds must have an entry in endpoints. A record cannot be published for a workload that was not deployed."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
    precondition {
      condition     = !local.gcp_enabled || var.placement.gcp != null
      error_message = "placement.gcp is required when gcp is in scope."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project      = var.landing_zone
  environment  = var.environment
  domain_name  = var.domain_name
  alb_dns_name = var.endpoints["aws"].dns_name
  alb_zone_id  = var.endpoints["aws"].zone_id
  create_zone  = var.create_public_zone
  tags         = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project             = var.landing_zone
  environment         = var.environment
  resource_group_name = var.placement.azure.resource_group_name
  vnet_id             = var.networks["azure"].id
  domain_name         = var.domain_name
  lb_private_ip       = var.endpoints["azure"].address
  tags                = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project        = var.landing_zone
  environment    = var.environment
  gcp_project_id = var.placement.gcp.project_id
  domain_name    = var.domain_name
  lb_ip_address  = var.endpoints["gcp"].address

  depends_on = [terraform_data.guards]
}
