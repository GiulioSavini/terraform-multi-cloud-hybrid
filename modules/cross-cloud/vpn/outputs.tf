output "aws_vpn_connection_id" {
  description = "AWS VPN connection ID"
  value       = aws_vpn_connection.to_azure.id
}

output "aws_tunnel1_address" {
  description = "AWS VPN tunnel 1 address"
  value       = aws_vpn_connection.to_azure.tunnel1_address
}

output "azure_connection_id" {
  description = "Azure VPN connection ID"
  value       = azurerm_virtual_network_gateway_connection.to_aws.id
}
