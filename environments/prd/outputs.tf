output "aws_alb_dns_name" {
  value = module.aws_compute.alb_dns_name
}

output "azure_lb_public_ip" {
  value = module.azure_compute.lb_public_ip
}

output "gcp_lb_ip" {
  value = module.gcp_compute.lb_ip_address
}

output "vpn_connection_id" {
  value = try(module.cross_cloud_vpn[0].aws_vpn_connection_id, "VPN disabled")
}
