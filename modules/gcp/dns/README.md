# GCP DNS Module

Manages GCP Cloud DNS resources including managed zones, DNS record sets, and DNS peering for domain name resolution across networks.

## Usage

```hcl
module "gcp_dns" {
  source = "./modules/gcp/dns"

  project_id  = "my-gcp-project"
  dns_name    = "example.com."
  zone_name   = "example-com"
  description = "Production DNS zone"
  records = [
    {
      name    = "app.example.com."
      type    = "A"
      ttl     = 300
      rrdatas = ["10.2.1.100"]
    },
    {
      name    = "api.example.com."
      type    = "CNAME"
      ttl     = 300
      rrdatas = ["app.example.com."]
    }
  ]
  enable_private_zone = false
  environment         = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `dns_name` | The DNS name of the managed zone (must end with a dot) | `string` | n/a | yes |
| `zone_name` | The name of the managed zone | `string` | n/a | yes |
| `description` | Description for the managed zone | `string` | `""` | no |
| `records` | List of DNS record set configurations | `list(object)` | `[]` | no |
| `enable_private_zone` | Whether to create a private managed zone | `bool` | `false` | no |
| `private_visibility_networks` | List of VPC network self links for private zone visibility | `list(string)` | `[]` | no |
| `enable_dnssec` | Whether to enable DNSSEC for the zone | `bool` | `false` | no |
| `dnssec_state` | DNSSEC state (on, off, transfer) | `string` | `"on"` | no |
| `enable_peering` | Whether to enable DNS peering | `bool` | `false` | no |
| `peering_target_network` | Target network self link for DNS peering | `string` | `null` | no |
| `environment` | Environment name for labeling | `string` | n/a | yes |
| `labels` | Additional labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `managed_zone_id` | The ID of the managed zone |
| `managed_zone_name` | The name of the managed zone |
| `managed_zone_name_servers` | The name servers of the managed zone |
| `record_set_names` | List of DNS record set names |
| `managed_zone_dns_name` | The DNS name of the managed zone |
