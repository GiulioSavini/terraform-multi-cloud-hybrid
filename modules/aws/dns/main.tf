locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "aws/dns" })
  zone_id     = var.create_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# ------------------------------------------------------------------------------
# Route53 Zone
# ------------------------------------------------------------------------------
resource "aws_route53_zone" "main" {
  count = var.create_zone ? 1 : 0

  name    = var.domain_name
  comment = "Managed by Terraform - ${local.name_prefix}"

  tags = local.common_tags
}

data "aws_route53_zone" "existing" {
  count = var.create_zone ? 0 : 1

  name         = var.domain_name
  private_zone = false
}

# ------------------------------------------------------------------------------
# DNS Records
# ------------------------------------------------------------------------------
resource "aws_route53_record" "alb" {
  zone_id = local.zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = local.zone_id
  name    = "www.${var.environment}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.environment}.${var.domain_name}"]
}

# ------------------------------------------------------------------------------
# Health Check
# ------------------------------------------------------------------------------
resource "aws_route53_health_check" "alb" {
  fqdn              = var.alb_dns_name
  port               = 443
  type               = "HTTPS"
  resource_path      = "/health"
  failure_threshold  = 3
  request_interval   = 30
  measure_latency    = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-health"
  })
}
