locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ------------------------------------------------------------------------------
# VPC Network
# ------------------------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = "${local.name_prefix}-vpc"
  project                 = var.gcp_project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork" "web" {
  name                     = "${local.name_prefix}-web"
  project                  = var.gcp_project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.web_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "app" {
  name                     = "${local.name_prefix}-app"
  project                  = var.gcp_project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.app_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "data" {
  name                     = "${local.name_prefix}-data"
  project                  = var.gcp_project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.data_subnet_cidr
  private_ip_google_access = true
}

# ------------------------------------------------------------------------------
# Cloud Router + Cloud NAT
# ------------------------------------------------------------------------------
resource "google_compute_router" "main" {
  count = var.enable_cloud_nat ? 1 : 0

  name    = "${local.name_prefix}-router"
  project = var.gcp_project_id
  region  = var.region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "main" {
  count = var.enable_cloud_nat ? 1 : 0

  name                               = "${local.name_prefix}-nat"
  project                            = var.gcp_project_id
  router                             = google_compute_router.main[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ------------------------------------------------------------------------------
# Firewall Rules
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_health_check" {
  name    = "${local.name_prefix}-allow-health-check"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web-server"]
}

# Web tier: allow HTTP/HTTPS from internet to web-server tagged instances
resource "google_compute_firewall" "allow_web" {
  name    = "${local.name_prefix}-allow-web"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [var.web_subnet_cidr]
  target_tags   = ["web-server"]
}

# App tier: allow app ports from web subnet to app-server tagged instances
resource "google_compute_firewall" "allow_app" {
  name    = "${local.name_prefix}-allow-app"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["8080", "8443"]
  }

  source_ranges = [var.web_subnet_cidr]
  target_tags   = ["app-server"]
}

# Data tier: allow database ports from app subnet to data-server tagged instances
resource "google_compute_firewall" "allow_data" {
  name    = "${local.name_prefix}-allow-data"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["5432", "3306", "1433"]
  }

  source_ranges = [var.app_subnet_cidr]
  target_tags   = ["data-server"]
}

# Internal ICMP for diagnostics
resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "${local.name_prefix}-allow-internal-icmp"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.web_subnet_cidr, var.app_subnet_cidr, var.data_subnet_cidr]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "${local.name_prefix}-deny-all-ingress"
  project  = var.gcp_project_id
  network  = google_compute_network.main.name
  priority = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
