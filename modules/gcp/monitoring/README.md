# GCP Monitoring Module

Configures GCP monitoring infrastructure including Cloud Monitoring alert policies, notification channels, dashboards, log sinks, and log-based metrics.

## Usage

```hcl
module "gcp_monitoring" {
  source = "./modules/gcp/monitoring"

  project_id                = "my-gcp-project"
  notification_email        = "ops-team@example.com"
  alert_policy_display_name = "High CPU Utilization"
  alert_condition_threshold = 0.8
  log_sink_name             = "audit-log-sink"
  log_sink_destination      = "storage.googleapis.com/my-audit-logs-bucket"
  log_sink_filter           = "logName:\"cloudaudit.googleapis.com\""
  create_dashboard          = true
  environment               = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `notification_email` | Email address for alert notifications | `string` | n/a | yes |
| `alert_policy_display_name` | Display name for the alert policy | `string` | n/a | yes |
| `alert_condition_threshold` | Threshold value for the alert condition | `number` | `0.8` | no |
| `alert_condition_duration` | Duration for the alert condition | `string` | `"300s"` | no |
| `alert_condition_comparison` | Comparison type for the alert condition | `string` | `"COMPARISON_GT"` | no |
| `log_sink_name` | Name of the log sink | `string` | `null` | no |
| `log_sink_destination` | Destination for the log sink | `string` | `null` | no |
| `log_sink_filter` | Filter expression for the log sink | `string` | `""` | no |
| `create_dashboard` | Whether to create a monitoring dashboard | `bool` | `false` | no |
| `uptime_check_host` | Host for uptime check | `string` | `null` | no |
| `environment` | Environment name for labeling | `string` | n/a | yes |
| `labels` | Additional labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alert_policy_id` | The ID of the alert policy |
| `notification_channel_id` | The ID of the notification channel |
| `log_sink_writer_identity` | The writer identity of the log sink |
| `dashboard_id` | The ID of the monitoring dashboard |
| `uptime_check_id` | The ID of the uptime check |
