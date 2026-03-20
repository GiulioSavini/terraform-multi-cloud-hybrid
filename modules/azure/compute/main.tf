locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "azure/compute" })
}

# ------------------------------------------------------------------------------
# User Assigned Managed Identity
# ------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "vmss" {
  name                = "${local.name_prefix}-vmss-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Azure Load Balancer
# ------------------------------------------------------------------------------
resource "azurerm_public_ip" "lb" {
  name                = "${local.name_prefix}-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_lb" "main" {
  name                = "${local.name_prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = local.common_tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${local.name_prefix}-bepool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_probe" "https" {
  name                = "${local.name_prefix}-https-probe"
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = "Https"
  port                = 443
  request_path        = "/health"
  interval_in_seconds = 15
  number_of_probes    = 3
}

resource "azurerm_lb_rule" "https" {
  name                           = "${local.name_prefix}-https-rule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.https.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}

resource "azurerm_lb_probe" "http" {
  name                = "${local.name_prefix}-http-probe"
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = "Http"
  port                = 80
  request_path        = "/health"
  interval_in_seconds = 15
  number_of_probes    = 3
}

resource "azurerm_lb_rule" "http" {
  name                           = "${local.name_prefix}-http-rule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  enable_floating_ip             = false
}

# ------------------------------------------------------------------------------
# VM Scale Set
# ------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "${local.name_prefix}-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_sku
  instances           = var.instance_count
  admin_username      = var.admin_username
  upgrade_mode        = "Rolling"
  health_probe_id     = azurerm_lb_probe.https.id
  overprovision       = false

  zone_balance = var.environment == "prd"
  zones        = var.environment == "prd" ? ["1", "2", "3"] : ["1"]

  custom_data = base64encode(file("${path.module}/cloud_init.yaml"))

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vmss.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.environment == "prd" ? "Premium_LRS" : "Standard_LRS"
    disk_size_gb         = 30
  }

  network_interface {
    name    = "${local.name_prefix}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.app_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.main.id]
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vmss.id]
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 33
    max_unhealthy_instance_percent          = 33
    max_unhealthy_upgraded_instance_percent = 33
    pause_time_between_batches              = "PT10S"
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT30M"
  }

  boot_diagnostics {}

  tags = local.common_tags

  lifecycle {
    ignore_changes = [instances]
  }
}

# SSH key for VMSS (stored in Terraform state only)
resource "tls_private_key" "vmss" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ------------------------------------------------------------------------------
# Autoscale Settings
# ------------------------------------------------------------------------------
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "${local.name_prefix}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id

  profile {
    name = "default"

    capacity {
      default = var.instance_count
      minimum = var.min_instances
      maximum = var.max_instances
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = local.common_tags
}
