# ------------------------------------------------------------------------------
# Published contract of the workload-hosting context.
# ------------------------------------------------------------------------------

output "endpoints" {
  description = "Reachable address of the workload per cloud, for the service-discovery context to publish."
  value = merge(
    local.aws_enabled ? { aws = {
      dns_name = module.aws[0].alb_dns_name
      zone_id  = module.aws[0].alb_zone_id
      address  = null
    } } : {},
    local.azure_enabled ? { azure = {
      dns_name = null
      zone_id  = null
      address  = module.azure[0].lb_public_ip
    } } : {},
    local.gcp_enabled ? { gcp = {
      dns_name = null
      zone_id  = null
      address  = module.gcp[0].lb_ip_address
    } } : {},
  )
}

output "workload_refs" {
  description = <<-EOT
    Handles the observability context needs to attach metrics and alarms.
    These are monitoring identifiers, not addresses — keep them out of
    `endpoints` so a consumer cannot accidentally route to one.
  EOT
  value = merge(
    local.aws_enabled ? { aws = {
      alb_arn_suffix = module.aws[0].alb_arn_suffix
      asg_name       = module.aws[0].asg_name
    } } : {},
    local.azure_enabled ? { azure = {
      vmss_id = module.azure[0].vmss_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      instance_group = module.gcp[0].instance_group
    } } : {},
  )
}

output "capacity" {
  description = "Effective capacity of the workload. Read by compliance/controls as availability evidence."
  value       = var.capacity
}

output "tls_enabled" {
  description = "Whether the AWS listener terminates TLS. Evidence for ISO 27001 A.8.24 and SOC 2 CC6.7."
  value       = local.aws_enabled ? length(var.ssl_certificate_arn) > 0 : null
}
