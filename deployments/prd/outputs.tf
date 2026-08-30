output "fqdns" {
  description = "Names the workload answers on."
  value       = module.landing_zone.fqdns
}

output "endpoints" {
  description = "Load balancer addresses per cloud."
  value       = module.landing_zone.endpoints
}

output "compliance_evidence" {
  description = "Control evidence for this deployment, read from the context contracts."
  value       = module.landing_zone.compliance_evidence
}
