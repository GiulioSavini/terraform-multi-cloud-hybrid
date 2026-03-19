# Azure Network Module

Provisions Azure networking infrastructure including virtual networks, subnets, network security groups, route tables, and load balancers.

## Usage

```hcl
module "azure_network" {
  source = "./modules/azure/network"

  resource_group_name = "rg-network-prod"
  location            = "westeurope"
  vnet_name           = "vnet-main"
  vnet_address_space  = ["10.1.0.0/16"]
  subnets = {
    public = {
      address_prefixes = ["10.1.1.0/24"]
    }
    private = {
      address_prefixes = ["10.1.10.0/24"]
    }
  }
  environment = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `location` | Azure region for resource deployment | `string` | n/a | yes |
| `vnet_name` | Name of the virtual network | `string` | n/a | yes |
| `vnet_address_space` | Address space for the virtual network | `list(string)` | n/a | yes |
| `subnets` | Map of subnet configurations | `map(object)` | `{}` | no |
| `enable_ddos_protection` | Enable DDoS protection plan | `bool` | `false` | no |
| `create_nat_gateway` | Whether to create a NAT gateway | `bool` | `true` | no |
| `enable_load_balancer` | Whether to create a load balancer | `bool` | `false` | no |
| `dns_servers` | List of custom DNS servers | `list(string)` | `[]` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | The ID of the virtual network |
| `vnet_name` | The name of the virtual network |
| `vnet_address_space` | The address space of the virtual network |
| `subnet_ids` | Map of subnet names to their IDs |
| `nsg_ids` | Map of NSG names to their IDs |
| `nat_gateway_id` | The ID of the NAT gateway |
| `load_balancer_id` | The ID of the load balancer |
