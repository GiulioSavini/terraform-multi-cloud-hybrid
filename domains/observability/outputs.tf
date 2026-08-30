output "alert_channels" {
  description = "Where alarms are delivered, per cloud."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].sns_topic_arn } : {},
    local.azure_enabled ? { azure = module.azure[0].action_group_id } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].notification_channel_id } : {},
  )
}

output "log_workspaces" {
  description = "Log destinations per cloud."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].log_group_application_name } : {},
    local.azure_enabled ? { azure = module.azure[0].log_analytics_workspace_id } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].log_sink_name } : {},
  )
}

output "central_archive" {
  description = "Cross-cloud log archive, when enabled."
  value = local.central_logging_enabled ? {
    aws_log_group = module.cross_cloud[0].aws_centralized_log_group
    aws_bucket    = module.cross_cloud[0].aws_log_archive_bucket
    gcp_bucket    = module.cross_cloud[0].gcp_centralized_logs_bucket
  } : null
}

output "retention_days" {
  description = "Effective log retention. Evidence for ISO 27001 A.8.15, SOC 2 CC7.2 and NIS2 incident handling."
  value       = var.retention_days
}
