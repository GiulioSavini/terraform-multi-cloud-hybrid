locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ------------------------------------------------------------------------------
# Service Account for Compute Instances
# ------------------------------------------------------------------------------
resource "google_service_account" "compute" {
  account_id   = "${local.name_prefix}-compute"
  display_name = "Compute instances service account - ${var.environment}"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "compute_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.compute.email}"
}

resource "google_project_iam_member" "compute_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.compute.email}"
}

# ------------------------------------------------------------------------------
# Cloud Armor Security Policy
# ------------------------------------------------------------------------------
resource "google_compute_security_policy" "main" {
  name    = "${local.name_prefix}-security-policy"
  project = var.gcp_project_id

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }
    description = "Block XSS attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "1001"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }
    description = "Block SQL injection"
  }
}
