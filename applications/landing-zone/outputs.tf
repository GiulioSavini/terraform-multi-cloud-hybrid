output "networks" {
  description = "Network fabric published by the networking context."
  value       = module.networking.networks
}

output "fqdns" {
  description = "Names the workload answers on."
  value       = module.service_discovery.fqdns
}

output "endpoints" {
  description = "Load balancer addresses per cloud."
  value       = module.workload_hosting.endpoints
}

output "alert_channels" {
  description = "Where alarms are delivered."
  value       = module.observability.alert_channels
}

output "compliance_evidence" {
  description = <<-EOT
    Control evidence gathered from the contracts, ready to be attached to an
    audit response. Every value here is read from a context output rather than
    asserted by hand, so it cannot claim a control the code does not implement.
  EOT
  value = {
    "NET-01" = module.networking.flow_logs_enabled
    "NET-03" = module.networking.cross_cloud_connected
    "IAM-02" = module.access_control.public_ingress_cidrs
    "APP-01" = module.workload_hosting.tls_enabled
    "APP-02" = module.workload_hosting.capacity
    "LOG-01" = module.observability.retention_days
    "LOG-02" = module.observability.alert_channels
  }
}

output "control_catalog" {
  description = "Controls this landing zone claims, grouped by framework."
  value       = module.controls.by_framework
}
