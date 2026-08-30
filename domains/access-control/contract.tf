# ------------------------------------------------------------------------------
# Bounded context: access-control
#
# Owns who and what may reach a workload: network perimeter (security groups,
# NSG rules, Cloud Armor policies) and workload identity (instance profiles,
# managed identities, service accounts).
#
# It attaches to the fabric published by the networking context and never
# creates networks of its own. Consumers read the contract in outputs.tf.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks. This context cannot attach a perimeter to a fabric that was not provisioned."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
    precondition {
      condition     = !local.gcp_enabled || var.placement.gcp != null
      error_message = "placement.gcp is required when gcp is in scope."
    }
    precondition {
      condition     = length(var.alb_ingress_cidrs) > 0
      error_message = "alb_ingress_cidrs must contain at least one CIDR. An empty list produces a load balancer nothing can reach."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project           = var.landing_zone
  environment       = var.environment
  vpc_id            = var.networks["aws"].id
  alb_ingress_cidrs = var.alb_ingress_cidrs
  tags              = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project             = var.landing_zone
  environment         = var.environment
  resource_group_name = var.placement.azure.resource_group_name
  location            = var.placement.azure.location
  tenant_id           = var.placement.azure.tenant_id

  # Key Vault reaches only the tiers that run workloads; the data tier holds no
  # compute in this landing zone.
  allowed_subnet_ids = concat(
    var.networks["azure"].subnets.web,
    var.networks["azure"].subnets.app,
  )

  tags = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project        = var.landing_zone
  environment    = var.environment
  gcp_project_id = var.placement.gcp.project_id

  depends_on = [terraform_data.guards]
}
