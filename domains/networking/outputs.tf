# ------------------------------------------------------------------------------
# Published contract of the networking context.
#
# Everything here has the same shape regardless of which clouds are enabled, so
# a consumer writes one expression instead of three provider-specific branches.
# Adding a field is backwards compatible; changing the shape of one is not.
# ------------------------------------------------------------------------------

locals {
  networks = merge(
    local.aws_enabled ? {
      aws = {
        id   = module.aws[0].vpc_id
        cidr = module.aws[0].vpc_cidr
        subnets = {
          # AWS spreads each tier across availability zones, so every tier is a
          # list. Azure and GCP are wrapped below to match.
          web  = module.aws[0].public_subnet_ids
          app  = module.aws[0].private_subnet_ids
          data = module.aws[0].data_subnet_ids
        }
      }
    } : {},
    local.azure_enabled ? {
      azure = {
        id   = module.azure[0].vnet_id
        cidr = var.address_space.azure
        subnets = {
          web  = [module.azure[0].web_subnet_id]
          app  = [module.azure[0].app_subnet_id]
          data = [module.azure[0].data_subnet_id]
        }
      }
    } : {},
    local.gcp_enabled ? {
      gcp = {
        id   = module.gcp[0].network_id
        cidr = var.address_space.gcp
        subnets = {
          web  = [module.gcp[0].web_subnet_id]
          app  = [module.gcp[0].app_subnet_id]
          data = [module.gcp[0].data_subnet_id]
        }
      }
    } : {},
  )
}

output "networks" {
  description = "Uniform per-cloud view of the fabric: id, cidr and subnet ids by tier (web, app, data)."
  value       = local.networks
}

output "clouds" {
  description = "Clouds actually provisioned by this context."
  value       = sort(keys(local.networks))
}

output "cross_cloud_connected" {
  description = "Whether the AWS<->Azure IPsec tunnels were established."
  value       = local.cross_cloud_enabled
}

output "flow_logs_enabled" {
  description = "Whether flow logging is active. Read by compliance/controls as evidence for CIS 3.x and ISO 27001 A.8.15."
  value       = var.flow_logs_enabled
}

output "azure_nsg_ids" {
  description = "Azure NSG ids, needed by the access-control context to attach rules. Empty when azure is not in scope."
  value = local.azure_enabled ? {
    web = module.azure[0].web_nsg_id
    app = module.azure[0].app_nsg_id
  } : {}
}

output "gcp_self_links" {
  description = <<-EOT
    GCP resource self links. The GCP compute API addresses networks by self
    link rather than by id, so consumers in the workload-hosting context need
    these in addition to the ids published in `networks`.
  EOT
  value = local.gcp_enabled ? {
    network    = module.gcp[0].network_self_link
    web_subnet = module.gcp[0].web_subnet_self_link
  } : {}
}
