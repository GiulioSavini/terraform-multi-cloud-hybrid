locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "azure/dns" })
}

resource "azurerm_private_dns_zone" "main" {
  name                = "${var.environment}.${var.domain_name}"
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${local.name_prefix}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
  tags                  = local.common_tags
}

resource "azurerm_private_dns_a_record" "app" {
  count = var.lb_private_ip != "" ? 1 : 0

  name                = "app"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.lb_private_ip]
  tags                = local.common_tags
}
