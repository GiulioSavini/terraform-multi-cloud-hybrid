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

resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name_prefix}-allow-internal"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

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
