output "zone_id" {
  description = "Route53 zone ID"
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers for the zone"
  value       = var.create_zone ? aws_route53_zone.main[0].name_servers : []
}

output "alb_fqdn" {
  description = "FQDN of the ALB record"
  value       = aws_route53_record.alb.fqdn
}

output "health_check_id" {
  description = "ID of the Route53 health check"
  value       = aws_route53_health_check.alb.id
}
