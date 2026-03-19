locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "azure/monitoring" })
}

# ------------------------------------------------------------------------------
# Log Analytics Workspace
# ------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Application Insights
# ------------------------------------------------------------------------------
resource "azurerm_application_insights" "main" {
  name                = "${local.name_prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Action Group
# ------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "main" {
  name                = "${local.name_prefix}-ag"
  resource_group_name = var.resource_group_name
  short_name          = substr(local.name_prefix, 0, 12)

  dynamic "email_receiver" {
    for_each = var.alarm_email != "" ? [1] : []
    content {
      name          = "admin"
      email_address = var.alarm_email
    }
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Metric Alerts
# ------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "${local.name_prefix}-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.vmss_id]
  description         = "Alert when CPU exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "memory" {
  name                = "${local.name_prefix}-high-memory"
  resource_group_name = var.resource_group_name
  scopes              = [var.vmss_id]
  description         = "Alert when available memory is low"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1073741824 # 1 GB
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.common_tags
}
