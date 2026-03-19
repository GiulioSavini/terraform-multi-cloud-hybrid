# AWS Network Module

Provisions AWS networking infrastructure including VPC, public and private subnets, internet gateway, NAT gateway, and route tables.

## Usage

```hcl
module "aws_network" {
  source = "./modules/aws/network"

  vpc_cidr_block     = "10.0.0.0/16"
  vpc_name           = "main-vpc"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = true
  environment        = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_cidr_block` | The CIDR block for the VPC | `string` | n/a | yes |
| `vpc_name` | Name tag for the VPC | `string` | n/a | yes |
| `availability_zones` | List of availability zones to deploy subnets into | `list(string)` | n/a | yes |
| `public_subnets` | List of CIDR blocks for public subnets | `list(string)` | `[]` | no |
| `private_subnets` | List of CIDR blocks for private subnets | `list(string)` | `[]` | no |
| `enable_nat_gateway` | Whether to create a NAT gateway for private subnets | `bool` | `true` | no |
| `single_nat_gateway` | Use a single NAT gateway instead of one per AZ | `bool` | `false` | no |
| `enable_dns_support` | Enable DNS support in the VPC | `bool` | `true` | no |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vpc_cidr_block` | The CIDR block of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_ids` | List of NAT gateway IDs |
| `internet_gateway_id` | The ID of the internet gateway |
| `public_route_table_id` | The ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |
