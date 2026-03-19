locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ------------------------------------------------------------------------------
# Notification Channel
# ------------------------------------------------------------------------------
resource "google_monitoring_notification_channel" "email" {
  count = var.notification_email != "" ? 1 : 0

  display_name = "${local.name_prefix} Email"
  project      = var.gcp_project_id
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

# ------------------------------------------------------------------------------
# Uptime Check
# ------------------------------------------------------------------------------
resource "google_monitoring_uptime_check_config" "https" {
  count = var.lb_ip_address != "" ? 1 : 0

  display_name = "${local.name_prefix}-https-uptime"
  project      = var.gcp_project_id
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = 443
    use_ssl      = true
    validate_ssl = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = var.lb_ip_address
    }
  }
}

# ------------------------------------------------------------------------------
# Alert Policies
# ------------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "${local.name_prefix} - High CPU"
  project      = var.gcp_project_id
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > 80%"

    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  alert_strategy {
    auto_close = "604800s"
  }
}

resource "google_monitoring_alert_policy" "uptime_failure" {
  count = var.lb_ip_address != "" ? 1 : 0

  display_name = "${local.name_prefix} - Uptime Check Failed"
  project      = var.gcp_project_id
  combiner     = "OR"

  conditions {
    display_name = "Uptime check failing"

    condition_threshold {
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.*"]
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []
}

# ------------------------------------------------------------------------------
# Log Sink (export to BigQuery for analysis)
# ------------------------------------------------------------------------------
resource "google_logging_project_sink" "bigquery" {
  name        = "${local.name_prefix}-log-sink"
  project     = var.gcp_project_id
  destination = "bigquery.googleapis.com/projects/${var.gcp_project_id}/datasets/${google_bigquery_dataset.logs.dataset_id}"
  filter      = "resource.type = \"gce_instance\" OR resource.type = \"http_load_balancer\""

  unique_writer_identity = true
}

resource "google_bigquery_dataset" "logs" {
  dataset_id = replace("${local.name_prefix}_logs", "-", "_")
  project    = var.gcp_project_id
  location   = "EU"

  default_table_expiration_ms = var.environment == "prd" ? 7776000000 : 2592000000 # 90 or 30 days

  labels = {
    environment = var.environment
  }
}

resource "google_project_iam_member" "log_sink_writer" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.bigquery.writer_identity
}
