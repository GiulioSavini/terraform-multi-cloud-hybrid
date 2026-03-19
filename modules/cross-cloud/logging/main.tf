locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "cross-cloud/logging" })
}

# ==============================================================================
# AWS - Centralized Log Group + Export
# ==============================================================================

resource "aws_cloudwatch_log_group" "centralized" {
  name              = "/${local.name_prefix}/centralized"
  retention_in_days = var.retention_days

  tags = local.common_tags
}

resource "aws_s3_bucket" "log_archive" {
  bucket        = "${local.name_prefix}-log-archive-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment != "prd"

  tags = local.common_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

# ==============================================================================
# Azure - Log Analytics Query for centralized view
# ==============================================================================

resource "azurerm_log_analytics_saved_search" "cross_cloud" {
  name                       = "CrossCloudOverview"
  log_analytics_workspace_id = var.azure_log_analytics_workspace_id
  category                   = "Cross-Cloud"
  display_name               = "Cross-Cloud Log Overview"

  query = <<-QUERY
    union
      (AzureActivity | project TimeGenerated, Cloud="Azure", Resource=Resource, Action=OperationNameValue, Status=ActivityStatusValue),
      (AzureMetrics | project TimeGenerated, Cloud="Azure", Resource=Resource, Action=MetricName, Status="metric")
    | sort by TimeGenerated desc
    | take 1000
  QUERY
}

# ==============================================================================
# GCP - Log Sink to centralized bucket
# ==============================================================================

resource "google_logging_project_sink" "centralized" {
  name        = "${local.name_prefix}-centralized-sink"
  project     = var.gcp_project_id
  destination = "storage.googleapis.com/${google_storage_bucket.centralized_logs.name}"
  filter      = "severity >= WARNING"

  unique_writer_identity = true
}

resource "google_storage_bucket" "centralized_logs" {
  name          = "${local.name_prefix}-centralized-logs-gcp"
  project       = var.gcp_project_id
  location      = "EU"
  force_destroy = var.environment != "prd"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    purpose     = "centralized-logging"
  }
}

resource "google_storage_bucket_iam_member" "log_sink_writer" {
  bucket = google_storage_bucket.centralized_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.centralized.writer_identity
}
