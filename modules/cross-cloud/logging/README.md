# Cross-Cloud Logging Module

Provides centralized log aggregation across AWS, Azure, and GCP cloud environments, enabling unified log collection, forwarding, and storage in a single destination.

## Usage

```hcl
module "cross_cloud_logging" {
  source = "./modules/cross-cloud/logging"

  logging_name = "central-logging"

  # Central destination (S3 bucket in this example)
  central_log_destination = "s3"
  s3_bucket_name          = "central-logs-production"
  s3_bucket_region        = "us-east-1"

  # AWS log sources
  enable_aws_logs          = true
  aws_cloudwatch_log_groups = ["/app/production", "/app/api"]
  aws_region               = "us-east-1"

  # Azure log sources
  enable_azure_logs              = true
  azure_log_analytics_workspace_id = module.azure_monitoring.log_analytics_workspace_id
  azure_resource_group_name      = "rg-logging-prod"
  azure_location                 = "westeurope"

  # GCP log sources
  enable_gcp_logs  = true
  gcp_project_id   = "my-gcp-project"
  gcp_log_filter   = "severity >= WARNING"

  log_retention_days = 365
  environment        = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `logging_name` | Name prefix for all logging resources | `string` | n/a | yes |
| `central_log_destination` | Central log destination type (s3, gcs, azure_blob) | `string` | `"s3"` | no |
| `s3_bucket_name` | S3 bucket name for central log storage | `string` | `null` | no |
| `s3_bucket_region` | AWS region for the S3 bucket | `string` | `null` | no |
| `gcs_bucket_name` | GCS bucket name for central log storage | `string` | `null` | no |
| `azure_storage_account_name` | Azure storage account for central log storage | `string` | `null` | no |
| `enable_aws_logs` | Whether to collect logs from AWS | `bool` | `false` | no |
| `aws_cloudwatch_log_groups` | List of CloudWatch log group names to forward | `list(string)` | `[]` | no |
| `aws_region` | AWS region for logging resources | `string` | `null` | no |
| `enable_azure_logs` | Whether to collect logs from Azure | `bool` | `false` | no |
| `azure_log_analytics_workspace_id` | Azure Log Analytics workspace ID for log export | `string` | `null` | no |
| `azure_resource_group_name` | Azure resource group for logging resources | `string` | `null` | no |
| `azure_location` | Azure region for logging resources | `string` | `null` | no |
| `enable_gcp_logs` | Whether to collect logs from GCP | `bool` | `false` | no |
| `gcp_project_id` | GCP project ID for logging resources | `string` | `null` | no |
| `gcp_log_filter` | Filter for GCP log sink | `string` | `""` | no |
| `log_retention_days` | Number of days to retain centralized logs | `number` | `90` | no |
| `enable_log_encryption` | Whether to encrypt logs at rest | `bool` | `true` | no |
| `environment` | Environment name for tagging and labeling | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `central_log_bucket_arn` | The ARN or ID of the central log storage bucket |
| `aws_log_subscription_arns` | List of CloudWatch log subscription filter ARNs |
| `azure_diagnostic_setting_ids` | List of Azure diagnostic setting IDs |
| `gcp_log_sink_writer_identity` | The writer identity of the GCP log sink |
| `log_forwarding_role_arns` | ARNs of IAM roles used for log forwarding |
| `encryption_key_id` | The ID of the encryption key used for log storage |
