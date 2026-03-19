locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ------------------------------------------------------------------------------
# Instance Template
# ------------------------------------------------------------------------------
resource "google_compute_instance_template" "main" {
  name_prefix  = "${local.name_prefix}-tmpl-"
  project      = var.gcp_project_id
  machine_type = var.machine_type
  region       = var.region

  tags = ["web-server", var.environment]

  disk {
    source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = 20

    disk_encryption_key {
      kms_key_self_link = ""
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  metadata = {
    startup-script = file("${path.module}/startup_script.sh")
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Managed Instance Group
# ------------------------------------------------------------------------------
resource "google_compute_region_instance_group_manager" "main" {
  name               = "${local.name_prefix}-mig"
  project            = var.gcp_project_id
  region             = var.region
  base_instance_name = "${local.name_prefix}-vm"

  version {
    instance_template = google_compute_instance_template.main.id
  }

  named_port {
    name = "https"
    port = 443
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.main.id
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = var.environment == "prd" ? 3 : 1
    max_unavailable_fixed        = 0
    instance_redistribution_type = "PROACTIVE"
  }
}

# ------------------------------------------------------------------------------
# Autoscaler
# ------------------------------------------------------------------------------
resource "google_compute_region_autoscaler" "main" {
  name    = "${local.name_prefix}-autoscaler"
  project = var.gcp_project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.main.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 300

    cpu_utilization {
      target = 0.7
    }
  }
}

# ------------------------------------------------------------------------------
# Health Check
# ------------------------------------------------------------------------------
resource "google_compute_health_check" "main" {
  name    = "${local.name_prefix}-hc"
  project = var.gcp_project_id

  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  https_health_check {
    port         = 443
    request_path = "/health"
  }
}

# ------------------------------------------------------------------------------
# HTTP(S) Load Balancer
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "main" {
  name    = "${local.name_prefix}-lb-ip"
  project = var.gcp_project_id
}

resource "google_compute_backend_service" "main" {
  name                  = "${local.name_prefix}-backend"
  project               = var.gcp_project_id
  protocol              = "HTTPS"
  port_name             = "https"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.main.id]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group           = google_compute_region_instance_group_manager.main.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
    capacity_scaler = 1.0
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "main" {
  name            = "${local.name_prefix}-urlmap"
  project         = var.gcp_project_id
  default_service = google_compute_backend_service.main.id
}

resource "google_compute_target_https_proxy" "main" {
  name    = "${local.name_prefix}-https-proxy"
  project = var.gcp_project_id
  url_map = google_compute_url_map.main.id

  ssl_certificates = [google_compute_managed_ssl_certificate.main.id]
}

resource "google_compute_managed_ssl_certificate" "main" {
  name    = "${local.name_prefix}-cert"
  project = var.gcp_project_id

  managed {
    domains = ["${var.environment}.hybrid.example.com"]
  }
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "${local.name_prefix}-fwd-https"
  project    = var.gcp_project_id
  target     = google_compute_target_https_proxy.main.id
  port_range = "443"
  ip_address = google_compute_global_address.main.address
}

# HTTP redirect to HTTPS
resource "google_compute_url_map" "http_redirect" {
  name    = "${local.name_prefix}-http-redirect"
  project = var.gcp_project_id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "${local.name_prefix}-http-proxy"
  project = var.gcp_project_id
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  name       = "${local.name_prefix}-fwd-http"
  project    = var.gcp_project_id
  target     = google_compute_target_http_proxy.redirect.id
  port_range = "80"
  ip_address = google_compute_global_address.main.address
}
