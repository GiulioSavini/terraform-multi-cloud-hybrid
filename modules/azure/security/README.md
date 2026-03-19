# Azure Security Module

Manages Azure security resources including Azure AD role assignments, Key Vault for secrets management, managed identities, and network security policies.

## Usage

```hcl
module "azure_security" {
  source = "./modules/azure/security"

  resource_group_name   = "rg-security-prod"
  location              = "westeurope"
  key_vault_name        = "kv-app-prod"
  create_key_vault      = true
  managed_identity_name = "mi-app-prod"
  key_vault_sku         = "standard"
  allowed_ip_ranges     = ["203.0.113.0/24"]
  environment           = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `location` | Azure region for resource deployment | `string` | n/a | yes |
| `key_vault_name` | Name of the Azure Key Vault | `string` | n/a | yes |
| `create_key_vault` | Whether to create a Key Vault | `bool` | `true` | no |
| `key_vault_sku` | SKU for the Key Vault (standard or premium) | `string` | `"standard"` | no |
| `managed_identity_name` | Name of the user-assigned managed identity | `string` | n/a | yes |
| `role_assignments` | List of role assignment configurations | `list(object)` | `[]` | no |
| `allowed_ip_ranges` | List of IP ranges allowed to access Key Vault | `list(string)` | `[]` | no |
| `enable_purge_protection` | Enable purge protection on Key Vault | `bool` | `true` | no |
| `soft_delete_retention_days` | Number of days for soft delete retention | `number` | `90` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `key_vault_id` | The ID of the Key Vault |
| `key_vault_uri` | The URI of the Key Vault |
| `managed_identity_id` | The ID of the managed identity |
| `managed_identity_principal_id` | The principal ID of the managed identity |
| `managed_identity_client_id` | The client ID of the managed identity |
