# ------------------------------------------------------------------------------
# Bounded context: networking
#
# Owns the network fabric — address space, subnet tiers and the connectivity
# between clouds. Consumers depend on the uniform shape published in
# outputs.tf; they must not reference ./aws, ./azure or ./gcp directly. Those
# are adapters and their interfaces change with the provider, not with the
# domain.
#
# Invariants are documented in README.md and enforced below by preconditions.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  # Cross-cloud connectivity in this landing zone is an AWS<->Azure IPsec pair.
  # GCP joins the fabric through its own peering and is not part of the tunnel.
  cross_cloud_possible = local.aws_enabled && local.azure_enabled
  cross_cloud_enabled  = var.enable_cross_cloud_connectivity && local.cross_cloud_possible
}

# --- Guards ------------------------------------------------------------------
# Failing here at plan time is the whole point: each of these misconfigurations
# otherwise produces infrastructure that applies successfully and does not work.

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = !local.aws_enabled || var.placement.aws != null
      error_message = "placement.aws is required when aws is listed in clouds."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is listed in clouds."
    }
    precondition {
      condition     = !local.gcp_enabled || var.placement.gcp != null
      error_message = "placement.gcp is required when gcp is listed in clouds."
    }
    precondition {
      condition     = !var.enable_cross_cloud_connectivity || local.cross_cloud_possible
      error_message = "enable_cross_cloud_connectivity requires both aws and azure in clouds; the tunnel pair has no other endpoints."
    }
    precondition {
      condition     = !local.cross_cloud_enabled || length(var.cross_cloud_shared_key) >= 20
      error_message = "cross_cloud_shared_key must be at least 20 characters when cross-cloud connectivity is enabled."
    }
    precondition {
      condition = !(local.aws_enabled && local.azure_enabled) || (
        cidrhost(var.address_space.aws, 0) != cidrhost(var.address_space.azure, 0)
      )
      error_message = "address_space.aws and address_space.azure must not start at the same address; overlapping ranges blackhole cross-cloud traffic."
    }
    precondition {
      condition     = !(local.azure_enabled && var.flow_logs_enabled) || length(var.flow_log_storage_account_id) > 0
      error_message = "flow_log_storage_account_id is required when flow logs are enabled and azure is in scope. Azure NSG flow logs have nowhere to land without it."
    }
  }
}

# --- Adapters ----------------------------------------------------------------

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project            = var.landing_zone
  environment        = var.environment
  vpc_cidr           = var.address_space.aws
  availability_zones = var.placement.aws.availability_zones
  enable_flow_logs   = var.flow_logs_enabled
  enable_vpn_gateway = local.cross_cloud_enabled
  tags               = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project                     = var.landing_zone
  environment                 = var.environment
  vnet_cidr                   = var.address_space.azure
  location                    = var.placement.azure.location
  resource_group_name         = var.placement.azure.resource_group_name
  enable_vpn_gateway          = local.cross_cloud_enabled
  flow_log_storage_account_id = var.flow_logs_enabled ? var.flow_log_storage_account_id : ""
  tags                        = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project        = var.landing_zone
  environment    = var.environment
  gcp_project_id = var.placement.gcp.project_id
  region         = var.placement.gcp.region

  # The GCP adapter takes per-tier CIDRs rather than one block. Carving them
  # here keeps address allocation a single decision at the contract boundary.
  web_subnet_cidr  = cidrsubnet(var.address_space.gcp, 8, 1)
  app_subnet_cidr  = cidrsubnet(var.address_space.gcp, 8, 2)
  data_subnet_cidr = cidrsubnet(var.address_space.gcp, 8, 3)

  labels = var.labels

  depends_on = [terraform_data.guards]
}

module "cross_cloud" {
  count  = local.cross_cloud_enabled ? 1 : 0
  source = "./cross-cloud"

  project     = var.landing_zone
  environment = var.environment

  aws_vpn_gateway_id = module.aws[0].vpn_gateway_id
  aws_vpc_cidr       = var.address_space.aws

  azure_vpn_gateway_id        = module.azure[0].vpn_gateway_id
  azure_vpn_gateway_public_ip = module.azure[0].vpn_gateway_public_ip
  azure_vnet_cidr             = var.address_space.azure
  azure_resource_group_name   = var.placement.azure.resource_group_name
  azure_location              = var.placement.azure.location

  shared_key = var.cross_cloud_shared_key
  tags       = var.tags
}
