# GCP Compute Module

Provisions GCP compute resources including Compute Engine instances, managed instance groups, and instance templates with configurable machine types and autoscaling.

## Usage

```hcl
module "gcp_compute" {
  source = "./modules/gcp/compute"

  project_id      = "my-gcp-project"
  zone            = "us-central1-a"
  instance_name   = "vm-app"
  machine_type    = "e2-medium"
  subnet_self_link = module.gcp_network.subnet_self_links["subnet-private"]
  image           = "ubuntu-os-cloud/ubuntu-2204-lts"
  disk_size_gb    = 50
  service_account_email = module.gcp_security.service_account_email
  environment     = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `zone` | GCP zone for instance deployment | `string` | n/a | yes |
| `instance_name` | Name of the compute instance | `string` | n/a | yes |
| `machine_type` | Machine type for the instance | `string` | `"e2-medium"` | no |
| `subnet_self_link` | Self link of the subnet for the instance | `string` | n/a | yes |
| `image` | Boot disk image | `string` | `"ubuntu-os-cloud/ubuntu-2204-lts"` | no |
| `disk_size_gb` | Size of the boot disk in GB | `number` | `20` | no |
| `disk_type` | Type of the boot disk | `string` | `"pd-standard"` | no |
| `service_account_email` | Service account email to attach to the instance | `string` | `null` | no |
| `enable_instance_group` | Whether to create a managed instance group | `bool` | `false` | no |
| `instance_group_size` | Target size of the managed instance group | `number` | `2` | no |
| `enable_autoscaling` | Whether to enable autoscaling | `bool` | `false` | no |
| `min_replicas` | Minimum number of replicas for autoscaling | `number` | `1` | no |
| `max_replicas` | Maximum number of replicas for autoscaling | `number` | `5` | no |
| `environment` | Environment name for labeling | `string` | n/a | yes |
| `labels` | Additional labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The ID of the compute instance |
| `instance_self_link` | The self link of the compute instance |
| `instance_private_ip` | The internal IP address of the instance |
| `instance_public_ip` | The external IP address of the instance (if assigned) |
| `instance_template_id` | The ID of the instance template |
| `instance_group_id` | The ID of the managed instance group |
