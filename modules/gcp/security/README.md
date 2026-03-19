# GCP Security Module

Manages GCP security resources including IAM bindings, service accounts, Cloud KMS keys, and organization policy constraints for securing cloud resources.

## Usage

```hcl
module "gcp_security" {
  source = "./modules/gcp/security"

  project_id           = "my-gcp-project"
  service_account_name = "sa-app-prod"
  service_account_display_name = "Application Service Account"
  iam_roles            = ["roles/storage.objectViewer", "roles/logging.logWriter"]
  create_kms_keyring   = true
  kms_keyring_name     = "keyring-app-prod"
  kms_keyring_location = "us-central1"
  kms_key_name         = "key-app-encryption"
  environment          = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `service_account_name` | Name of the service account | `string` | n/a | yes |
| `service_account_display_name` | Display name for the service account | `string` | `""` | no |
| `iam_roles` | List of IAM roles to grant to the service account | `list(string)` | `[]` | no |
| `create_kms_keyring` | Whether to create a KMS keyring and key | `bool` | `false` | no |
| `kms_keyring_name` | Name of the KMS keyring | `string` | `null` | no |
| `kms_keyring_location` | Location for the KMS keyring | `string` | `"us-central1"` | no |
| `kms_key_name` | Name of the KMS crypto key | `string` | `null` | no |
| `kms_key_rotation_period` | Rotation period for the KMS key | `string` | `"7776000s"` | no |
| `enable_org_policies` | Whether to enforce organization policy constraints | `bool` | `false` | no |
| `environment` | Environment name for labeling | `string` | n/a | yes |
| `labels` | Additional labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_account_email` | The email of the service account |
| `service_account_id` | The ID of the service account |
| `service_account_name` | The fully qualified name of the service account |
| `kms_keyring_id` | The ID of the KMS keyring |
| `kms_key_id` | The ID of the KMS crypto key |
| `kms_key_self_link` | The self link of the KMS crypto key |
