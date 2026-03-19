# AWS Compute Module

Provisions AWS compute resources including EC2 instances, auto scaling groups, and launch templates with configurable instance types and scaling policies.

## Usage

```hcl
module "aws_compute" {
  source = "./modules/aws/compute"

  instance_type    = "t3.medium"
  ami_id           = "ami-0abcdef1234567890"
  subnet_ids       = module.aws_network.private_subnet_ids
  security_groups  = [module.aws_security.app_security_group_id]
  key_name         = "my-key-pair"
  min_size         = 2
  max_size         = 6
  desired_capacity = 3
  environment      = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `instance_type` | EC2 instance type | `string` | `"t3.medium"` | no |
| `ami_id` | AMI ID for the EC2 instances | `string` | n/a | yes |
| `subnet_ids` | List of subnet IDs to launch instances in | `list(string)` | n/a | yes |
| `security_groups` | List of security group IDs to attach | `list(string)` | n/a | yes |
| `key_name` | SSH key pair name | `string` | `null` | no |
| `min_size` | Minimum number of instances in the auto scaling group | `number` | `1` | no |
| `max_size` | Maximum number of instances in the auto scaling group | `number` | `3` | no |
| `desired_capacity` | Desired number of instances in the auto scaling group | `number` | `2` | no |
| `root_volume_size` | Size of the root EBS volume in GB | `number` | `20` | no |
| `root_volume_type` | Type of the root EBS volume | `string` | `"gp3"` | no |
| `user_data` | Base64-encoded user data script | `string` | `null` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `autoscaling_group_id` | The ID of the auto scaling group |
| `autoscaling_group_name` | The name of the auto scaling group |
| `launch_template_id` | The ID of the launch template |
| `instance_ids` | List of EC2 instance IDs |
| `instance_private_ips` | List of private IP addresses of instances |
