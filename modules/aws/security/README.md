# AWS Security Module

Manages AWS security resources including IAM roles and policies, security groups, and KMS encryption keys for securing infrastructure and data.

## Usage

```hcl
module "aws_security" {
  source = "./modules/aws/security"

  vpc_id              = module.aws_network.vpc_id
  create_kms_key      = true
  kms_key_alias       = "app-encryption-key"
  allowed_ingress_cidrs = ["10.0.0.0/16"]
  iam_role_name       = "app-execution-role"
  iam_policy_arns     = ["arn:aws:iam::policy/AmazonS3ReadOnlyAccess"]
  environment         = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_id` | VPC ID for security group creation | `string` | n/a | yes |
| `create_kms_key` | Whether to create a KMS encryption key | `bool` | `true` | no |
| `kms_key_alias` | Alias for the KMS key | `string` | `null` | no |
| `kms_key_deletion_window` | Number of days before KMS key deletion | `number` | `30` | no |
| `allowed_ingress_cidrs` | List of CIDR blocks allowed for ingress | `list(string)` | `[]` | no |
| `allowed_ingress_ports` | List of ports to allow for ingress | `list(number)` | `[443]` | no |
| `iam_role_name` | Name of the IAM role to create | `string` | n/a | yes |
| `iam_policy_arns` | List of IAM policy ARNs to attach to the role | `list(string)` | `[]` | no |
| `enable_flow_logs` | Enable VPC flow logs | `bool` | `true` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `app_security_group_id` | The ID of the application security group |
| `iam_role_arn` | The ARN of the IAM role |
| `iam_role_name` | The name of the IAM role |
| `iam_instance_profile_arn` | The ARN of the IAM instance profile |
| `kms_key_arn` | The ARN of the KMS key |
| `kms_key_id` | The ID of the KMS key |
