locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "azure/network" })

  subnets = {
    web = {
      address_prefix    = cidrsubnet(var.vnet_cidr, 8, 1)
      service_endpoints = ["Microsoft.Web"]
    }
    app = {
      address_prefix    = cidrsubnet(var.vnet_cidr, 8, 2)
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    data = {
      address_prefix    = cidrsubnet(var.vnet_cidr, 8, 3)
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
    }
    gateway = {
      address_prefix    = cidrsubnet(var.vnet_cidr, 8, 254)
      service_endpoints = []
    }
  }
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------
resource "azurerm_subnet" "web" {
  name                 = "${local.name_prefix}-snet-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets.web.address_prefix]
  service_endpoints    = local.subnets.web.service_endpoints
}

resource "azurerm_subnet" "app" {
  name                 = "${local.name_prefix}-snet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets.app.address_prefix]
  service_endpoints    = local.subnets.app.service_endpoints
}

resource "azurerm_subnet" "data" {
  name                 = "${local.name_prefix}-snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets.data.address_prefix]
  service_endpoints    = local.subnets.data.service_endpoints
}

resource "azurerm_subnet" "gateway" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets.gateway.address_prefix]
}

# ------------------------------------------------------------------------------
# Network Security Groups
# ------------------------------------------------------------------------------
resource "azurerm_network_security_group" "web" {
  name                = "${local.name_prefix}-nsg-web"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "app" {
  name                = "${local.name_prefix}-nsg-app"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowFromWeb"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = local.subnets.web.address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "data" {
  name                = "${local.name_prefix}-nsg-data"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowFromApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["1433", "5432", "3306"]
    source_address_prefix      = local.subnets.app.address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# ------------------------------------------------------------------------------
# Route Table
# ------------------------------------------------------------------------------
resource "azurerm_route_table" "main" {
  name                = "${local.name_prefix}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = azurerm_route_table.main.id
}

# ------------------------------------------------------------------------------
# VPN Gateway (for cross-cloud)
# ------------------------------------------------------------------------------
resource "azurerm_public_ip" "vpn_gw" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "${local.name_prefix}-vpn-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_virtual_network_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "${local.name_prefix}-vpn-gw"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = var.environment == "prd" ? "VpnGw2" : "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway[0].id
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Network Watcher
# ------------------------------------------------------------------------------
resource "azurerm_network_watcher" "main" {
  name                = "${local.name_prefix}-nw"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Network Watcher Flow Log
# ------------------------------------------------------------------------------
resource "azurerm_network_watcher_flow_log" "web" {
  network_watcher_name = azurerm_network_watcher.main.name
  resource_group_name  = var.resource_group_name
  name                 = "${local.name_prefix}-nsg-web-flowlog"

  network_security_group_id = azurerm_network_security_group.web.id
  storage_account_id        = var.flow_log_storage_account_id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = var.environment == "prd" ? 90 : 30
  }

  tags = local.common_tags
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID used for NSG flow log storage"
  type        = string
  default     = ""
}
