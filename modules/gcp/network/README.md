# GCP Network Module

Provisions GCP networking infrastructure including VPC networks, subnets, firewall rules, Cloud Router, and Cloud NAT for outbound connectivity.

## Usage

```hcl
module "gcp_network" {
  source = "./modules/gcp/network"

  project_id   = "my-gcp-project"
  network_name = "vpc-main"
  subnets = [
    {
      name          = "subnet-public"
      ip_cidr_range = "10.2.1.0/24"
      region        = "us-central1"
    },
    {
      name          = "subnet-private"
      ip_cidr_range = "10.2.10.0/24"
      region        = "us-central1"
    }
  ]
  enable_cloud_nat = true
  environment      = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `network_name` | Name of the VPC network | `string` | n/a | yes |
| `auto_create_subnetworks` | Whether to auto-create subnetworks | `bool` | `false` | no |
| `routing_mode` | Network routing mode (REGIONAL or GLOBAL) | `string` | `"GLOBAL"` | no |
| `subnets` | List of subnet configurations | `list(object)` | `[]` | no |
| `firewall_rules` | List of firewall rule configurations | `list(object)` | `[]` | no |
| `enable_cloud_nat` | Whether to create Cloud NAT | `bool` | `true` | no |
| `cloud_nat_region` | Region for Cloud NAT | `string` | `"us-central1"` | no |
| `enable_private_google_access` | Enable Private Google Access on subnets | `bool` | `true` | no |
| `environment` | Environment name for labeling | `string` | n/a | yes |
| `labels` | Additional labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | The ID of the VPC network |
| `network_name` | The name of the VPC network |
| `network_self_link` | The self link of the VPC network |
| `subnet_ids` | Map of subnet names to their IDs |
| `subnet_self_links` | Map of subnet names to their self links |
| `cloud_router_id` | The ID of the Cloud Router |
| `cloud_nat_id` | The ID of the Cloud NAT |
