locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Module = "cross-cloud/vpn" })
}

# ==============================================================================
# AWS Side - Customer Gateway + VPN Connection
# ==============================================================================

resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = var.azure_vpn_gateway_public_ip
  type       = "ipsec.1"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cgw-azure"
  })
}

resource "aws_vpn_connection" "to_azure" {
  vpn_gateway_id      = var.aws_vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpn-to-azure"
  })
}

resource "aws_vpn_connection_route" "azure_vnet" {
  destination_cidr_block = var.azure_vnet_cidr
  vpn_connection_id      = aws_vpn_connection.to_azure.id
}

# ==============================================================================
# Azure Side - Local Network Gateway + Connection (Tunnel 1)
# ==============================================================================

resource "azurerm_local_network_gateway" "aws_tunnel1" {
  name                = "${local.name_prefix}-lgw-aws-tunnel1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  gateway_address = aws_vpn_connection.to_azure.tunnel1_address
  address_space   = [var.aws_vpc_cidr]

  tags = local.common_tags
}

resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel1" {
  name                       = "${local.name_prefix}-conn-to-aws-tunnel1"
  resource_group_name        = var.azure_resource_group_name
  location                   = var.azure_location
  type                       = "IPsec"
  virtual_network_gateway_id = var.azure_vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel1.id
  shared_key                 = var.shared_key

  ipsec_policy {
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    dh_group         = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_lifetime      = 3600
  }

  tags = local.common_tags
}

# ==============================================================================
# Azure Side - Local Network Gateway + Connection (Tunnel 2 - Redundancy)
# ==============================================================================

resource "azurerm_local_network_gateway" "aws_tunnel2" {
  name                = "${local.name_prefix}-lgw-aws-tunnel2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  gateway_address = aws_vpn_connection.to_azure.tunnel2_address
  address_space   = [var.aws_vpc_cidr]

  tags = local.common_tags
}

resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel2" {
  name                       = "${local.name_prefix}-conn-to-aws-tunnel2"
  resource_group_name        = var.azure_resource_group_name
  location                   = var.azure_location
  type                       = "IPsec"
  virtual_network_gateway_id = var.azure_vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel2.id
  shared_key                 = var.shared_key

  ipsec_policy {
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    dh_group         = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_lifetime      = 3600
  }

  tags = local.common_tags
}
