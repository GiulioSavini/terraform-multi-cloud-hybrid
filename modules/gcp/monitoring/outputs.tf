output "notification_channel_id" {
  description = "ID of the notification channel"
  value       = try(google_monitoring_notification_channel.email[0].name, null)
}

output "log_sink_name" {
  description = "Name of the log sink"
  value       = google_logging_project_sink.bigquery.name
}

output "logs_dataset_id" {
  description = "BigQuery dataset for logs"
  value       = google_bigquery_dataset.logs.dataset_id
}
