output "aws_centralized_log_group" {
  description = "AWS centralized log group name"
  value       = aws_cloudwatch_log_group.centralized.name
}

output "aws_log_archive_bucket" {
  description = "S3 bucket for log archive"
  value       = aws_s3_bucket.log_archive.id
}

output "gcp_centralized_logs_bucket" {
  description = "GCS bucket for centralized logs"
  value       = google_storage_bucket.centralized_logs.name
}
