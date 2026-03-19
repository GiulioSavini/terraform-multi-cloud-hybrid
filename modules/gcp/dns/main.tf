locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "google_dns_managed_zone" "main" {
  name        = "${local.name_prefix}-zone"
  project     = var.gcp_project_id
  dns_name    = "${var.environment}.${var.domain_name}."
  description = "DNS zone for ${var.environment} - managed by Terraform"

  dnssec_config {
    state = "on"
  }
}

resource "google_dns_record_set" "app" {
  name         = "app.${google_dns_managed_zone.main.dns_name}"
  project      = var.gcp_project_id
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.lb_ip_address]
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.main.dns_name}"
  project      = var.gcp_project_id
  managed_zone = google_dns_managed_zone.main.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["app.${google_dns_managed_zone.main.dns_name}"]
}
