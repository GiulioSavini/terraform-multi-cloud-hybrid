# Azure Compute Module

Provisions Azure compute resources including virtual machines, VM scale sets, and availability sets with configurable sizes and scaling policies.

## Usage

```hcl
module "azure_compute" {
  source = "./modules/azure/compute"

  resource_group_name = "rg-compute-prod"
  location            = "westeurope"
  vm_name             = "vm-app"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = module.azure_network.subnet_ids["private"]
  admin_username      = "azureadmin"
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  os_disk_size_gb     = 64
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts"
  environment         = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `location` | Azure region for resource deployment | `string` | n/a | yes |
| `vm_name` | Name of the virtual machine | `string` | n/a | yes |
| `vm_size` | Size of the virtual machine | `string` | `"Standard_D2s_v3"` | no |
| `subnet_id` | Subnet ID for the VM network interface | `string` | n/a | yes |
| `admin_username` | Admin username for the VM | `string` | n/a | yes |
| `ssh_public_key` | SSH public key for authentication | `string` | n/a | yes |
| `os_disk_size_gb` | Size of the OS disk in GB | `number` | `30` | no |
| `source_image_publisher` | Publisher of the source image | `string` | `"Canonical"` | no |
| `source_image_offer` | Offer of the source image | `string` | n/a | yes |
| `source_image_sku` | SKU of the source image | `string` | n/a | yes |
| `enable_scale_set` | Whether to create a VM scale set | `bool` | `false` | no |
| `scale_set_instances` | Number of instances in the scale set | `number` | `2` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | The ID of the virtual machine |
| `vm_private_ip` | The private IP address of the VM |
| `vm_public_ip` | The public IP address of the VM (if assigned) |
| `network_interface_id` | The ID of the network interface |
| `scale_set_id` | The ID of the VM scale set |
| `availability_set_id` | The ID of the availability set |
