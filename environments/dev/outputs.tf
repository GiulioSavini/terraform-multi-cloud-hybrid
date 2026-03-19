# AWS Outputs
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_network.vpc_id
}

output "aws_alb_dns_name" {
  description = "AWS ALB DNS name"
  value       = module.aws_compute.alb_dns_name
}

output "aws_alb_fqdn" {
  description = "AWS ALB FQDN"
  value       = module.aws_dns.alb_fqdn
}

# Azure Outputs
output "azure_vnet_id" {
  description = "Azure VNet ID"
  value       = module.azure_network.vnet_id
}

output "azure_lb_public_ip" {
  description = "Azure LB public IP"
  value       = module.azure_compute.lb_public_ip
}

output "azure_log_analytics_id" {
  description = "Azure Log Analytics workspace ID"
  value       = module.azure_monitoring.log_analytics_workspace_id
}

# GCP Outputs
output "gcp_network_name" {
  description = "GCP VPC network name"
  value       = module.gcp_network.network_name
}

output "gcp_lb_ip" {
  description = "GCP Load Balancer IP"
  value       = module.gcp_compute.lb_ip_address
}

# Cross-Cloud
output "centralized_logs_aws" {
  description = "AWS centralized log group"
  value       = module.cross_cloud_logging.aws_centralized_log_group
}

output "centralized_logs_gcp" {
  description = "GCP centralized logs bucket"
  value       = module.cross_cloud_logging.gcp_centralized_logs_bucket
}
