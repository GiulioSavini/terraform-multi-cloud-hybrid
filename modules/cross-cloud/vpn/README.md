# Cross-Cloud VPN Module

Establishes site-to-site VPN connectivity between AWS, Azure, and GCP cloud environments, enabling secure cross-cloud communication over encrypted tunnels.

## Usage

```hcl
module "cross_cloud_vpn" {
  source = "./modules/cross-cloud/vpn"

  vpn_name = "vpn-aws-to-gcp"

  # AWS side
  aws_vpc_id            = module.aws_network.vpc_id
  aws_subnet_ids        = module.aws_network.private_subnet_ids
  aws_route_table_ids   = module.aws_network.private_route_table_ids
  aws_region            = "us-east-1"

  # GCP side
  gcp_project_id        = "my-gcp-project"
  gcp_network_self_link = module.gcp_network.network_self_link
  gcp_region            = "us-central1"

  # Tunnel configuration
  shared_secret         = var.vpn_shared_secret
  tunnel_cidr_blocks    = ["169.254.10.0/30", "169.254.10.4/30"]
  enable_bgp            = true
  aws_bgp_asn           = 64512
  gcp_bgp_asn           = 64513

  environment = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpn_name` | Name prefix for all VPN resources | `string` | n/a | yes |
| `aws_vpc_id` | AWS VPC ID for the VPN connection | `string` | `null` | no |
| `aws_subnet_ids` | AWS subnet IDs for VPN routing | `list(string)` | `[]` | no |
| `aws_route_table_ids` | AWS route table IDs for propagation | `list(string)` | `[]` | no |
| `aws_region` | AWS region for VPN resources | `string` | `null` | no |
| `azure_resource_group_name` | Azure resource group for VPN resources | `string` | `null` | no |
| `azure_vnet_id` | Azure VNet ID for the VPN connection | `string` | `null` | no |
| `azure_gateway_subnet_id` | Azure gateway subnet ID | `string` | `null` | no |
| `azure_location` | Azure region for VPN resources | `string` | `null` | no |
| `gcp_project_id` | GCP project ID for VPN resources | `string` | `null` | no |
| `gcp_network_self_link` | GCP VPC network self link | `string` | `null` | no |
| `gcp_region` | GCP region for VPN resources | `string` | `null` | no |
| `shared_secret` | Pre-shared key for VPN tunnels | `string` | n/a | yes |
| `tunnel_cidr_blocks` | CIDR blocks for VPN tunnel interfaces | `list(string)` | `[]` | no |
| `enable_bgp` | Whether to enable BGP routing | `bool` | `true` | no |
| `aws_bgp_asn` | BGP ASN for the AWS side | `number` | `64512` | no |
| `azure_bgp_asn` | BGP ASN for the Azure side | `number` | `65515` | no |
| `gcp_bgp_asn` | BGP ASN for the GCP side | `number` | `64513` | no |
| `environment` | Environment name for tagging and labeling | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `aws_vpn_gateway_id` | The ID of the AWS VPN gateway |
| `aws_customer_gateway_ids` | List of AWS customer gateway IDs |
| `aws_vpn_connection_ids` | List of AWS VPN connection IDs |
| `azure_virtual_network_gateway_id` | The ID of the Azure virtual network gateway |
| `azure_local_network_gateway_ids` | List of Azure local network gateway IDs |
| `gcp_vpn_gateway_id` | The ID of the GCP VPN gateway |
| `gcp_vpn_tunnel_ids` | List of GCP VPN tunnel IDs |
| `tunnel_status` | Status of the VPN tunnels |
