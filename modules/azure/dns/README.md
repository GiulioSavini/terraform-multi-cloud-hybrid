# Azure DNS Module

Manages Azure DNS resources including public and private DNS zones, DNS records, and virtual network links for name resolution.

## Usage

```hcl
module "azure_dns" {
  source = "./modules/azure/dns"

  resource_group_name = "rg-dns-prod"
  domain_name         = "example.com"
  create_dns_zone     = true
  records = [
    {
      name  = "app"
      type  = "A"
      ttl   = 300
      value = "10.1.1.100"
    },
    {
      name  = "api"
      type  = "CNAME"
      ttl   = 300
      value = "app.example.com"
    }
  ]
  create_private_dns_zone = true
  private_dns_zone_name   = "privatelink.example.com"
  vnet_link_ids           = [module.azure_network.vnet_id]
  environment             = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `domain_name` | The domain name for the DNS zone | `string` | n/a | yes |
| `create_dns_zone` | Whether to create a public DNS zone | `bool` | `true` | no |
| `dns_zone_id` | Existing DNS zone ID (if not creating a new one) | `string` | `null` | no |
| `records` | List of DNS record objects to create | `list(object)` | `[]` | no |
| `create_private_dns_zone` | Whether to create a private DNS zone | `bool` | `false` | no |
| `private_dns_zone_name` | Name of the private DNS zone | `string` | `null` | no |
| `vnet_link_ids` | List of VNet IDs to link with private DNS zone | `list(string)` | `[]` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `dns_zone_id` | The ID of the public DNS zone |
| `dns_zone_name_servers` | The name servers for the DNS zone |
| `private_dns_zone_id` | The ID of the private DNS zone |
| `record_fqdns` | List of fully qualified domain names for created records |
| `vnet_link_ids` | List of virtual network link IDs |
