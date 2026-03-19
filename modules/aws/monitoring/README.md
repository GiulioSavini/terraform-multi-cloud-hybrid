# AWS Monitoring Module

Configures AWS monitoring infrastructure including CloudWatch alarms, dashboards, log groups, metric filters, and SNS notification topics.

## Usage

```hcl
module "aws_monitoring" {
  source = "./modules/aws/monitoring"

  alarm_namespace    = "CustomApp"
  alarm_metric_name  = "CPUUtilization"
  alarm_threshold    = 80
  alarm_period       = 300
  sns_topic_name     = "alerts-production"
  sns_email_endpoint = "ops-team@example.com"
  log_group_name     = "/app/production"
  log_retention_days = 90
  environment        = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `alarm_namespace` | CloudWatch namespace for the alarm | `string` | n/a | yes |
| `alarm_metric_name` | Metric name for the CloudWatch alarm | `string` | n/a | yes |
| `alarm_threshold` | Threshold value for the CloudWatch alarm | `number` | `80` | no |
| `alarm_period` | Evaluation period in seconds | `number` | `300` | no |
| `alarm_statistic` | Statistic for the alarm | `string` | `"Average"` | no |
| `alarm_comparison_operator` | Comparison operator for the alarm | `string` | `"GreaterThanOrEqualToThreshold"` | no |
| `sns_topic_name` | Name of the SNS topic for alarm notifications | `string` | n/a | yes |
| `sns_email_endpoint` | Email address for SNS notifications | `string` | `null` | no |
| `log_group_name` | Name of the CloudWatch log group | `string` | n/a | yes |
| `log_retention_days` | Number of days to retain logs | `number` | `30` | no |
| `create_dashboard` | Whether to create a CloudWatch dashboard | `bool` | `true` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cloudwatch_alarm_arn` | The ARN of the CloudWatch alarm |
| `sns_topic_arn` | The ARN of the SNS topic |
| `log_group_arn` | The ARN of the CloudWatch log group |
| `log_group_name` | The name of the CloudWatch log group |
| `dashboard_arn` | The ARN of the CloudWatch dashboard |
