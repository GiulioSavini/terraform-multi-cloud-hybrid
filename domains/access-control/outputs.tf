# ------------------------------------------------------------------------------
# Published contract of the access-control context.
# ------------------------------------------------------------------------------

output "workload_identity" {
  description = <<-EOT
    Identity each cloud's compute assumes. The workload-hosting context binds
    these to its instances; nothing else should consume them.
  EOT
  value = merge(
    local.aws_enabled ? { aws = {
      instance_profile_name = module.aws[0].instance_profile_name
      role_arn              = module.aws[0].ec2_role_arn
    } } : {},
    local.gcp_enabled ? { gcp = {
      service_account_email = module.gcp[0].compute_service_account_email
    } } : {},
  )
}

output "perimeter" {
  description = "Network perimeter handles by cloud, for attaching workloads and load balancers."
  value = merge(
    local.aws_enabled ? { aws = {
      alb_security_group_id      = module.aws[0].alb_security_group_id
      instance_security_group_id = module.aws[0].instance_security_group_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      security_policy_id        = module.gcp[0].security_policy_id
      security_policy_self_link = module.gcp[0].security_policy_self_link
    } } : {},
  )
}

output "secret_store" {
  description = "Managed secret store per cloud, where the context provisions one."
  value = local.azure_enabled ? {
    azure = {
      key_vault_id  = module.azure[0].key_vault_id
      key_vault_uri = module.azure[0].key_vault_uri
    }
  } : {}
}

output "public_ingress_cidrs" {
  description = "CIDRs permitted to reach public endpoints. Read by compliance/controls as evidence for CIS network exposure checks."
  value       = var.alb_ingress_cidrs
}
