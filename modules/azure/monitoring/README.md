# Azure Monitoring Module

Configures Azure monitoring infrastructure including Azure Monitor alert rules, Log Analytics workspaces, diagnostic settings, and action groups for notifications.

## Usage

```hcl
module "azure_monitoring" {
  source = "./modules/azure/monitoring"

  resource_group_name        = "rg-monitoring-prod"
  location                   = "westeurope"
  log_analytics_workspace_name = "law-prod"
  log_retention_days         = 90
  alert_email                = "ops-team@example.com"
  action_group_name          = "ag-critical-alerts"
  environment                = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `location` | Azure region for resource deployment | `string` | n/a | yes |
| `log_analytics_workspace_name` | Name of the Log Analytics workspace | `string` | n/a | yes |
| `log_analytics_sku` | SKU for the Log Analytics workspace | `string` | `"PerGB2018"` | no |
| `log_retention_days` | Number of days to retain logs | `number` | `30` | no |
| `alert_email` | Email address for alert notifications | `string` | n/a | yes |
| `action_group_name` | Name of the action group | `string` | n/a | yes |
| `metric_alerts` | List of metric alert rule configurations | `list(object)` | `[]` | no |
| `diagnostic_settings` | Map of diagnostic setting configurations | `map(object)` | `{}` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `log_analytics_workspace_id` | The ID of the Log Analytics workspace |
| `log_analytics_workspace_key` | The primary shared key of the Log Analytics workspace |
| `action_group_id` | The ID of the action group |
| `metric_alert_ids` | List of metric alert rule IDs |
