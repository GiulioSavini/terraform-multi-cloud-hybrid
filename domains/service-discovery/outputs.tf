output "fqdns" {
  description = "Fully qualified name the workload answers on, per cloud."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].alb_fqdn } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].app_fqdn } : {},
  )
}

output "public_zones" {
  description = "Public hosted zones and their delegation name servers."
  value = merge(
    local.aws_enabled ? { aws = {
      zone_id      = module.aws[0].zone_id
      name_servers = module.aws[0].name_servers
    } } : {},
    local.gcp_enabled ? { gcp = {
      zone_id      = module.gcp[0].zone_name
      name_servers = module.gcp[0].name_servers
    } } : {},
  )
}

output "private_zones" {
  description = "Private zones bound to the internal fabric."
  value = local.azure_enabled ? {
    azure = {
      zone_id   = module.azure[0].private_dns_zone_id
      zone_name = module.azure[0].private_dns_zone_name
    }
  } : {}
}
