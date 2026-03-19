# =============================================================================
# AWS-Only Example
# Deploys only the AWS landing zone: VPC + ALB + ASG + NGINX + CloudWatch
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="alarm_email=you@example.com"
#
# Estimated cost: ~$50/month
# Deploy time: ~5 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    tls = { source = "hashicorp/tls", version = "~> 4.0" }
  }
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  project     = "aws-example"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment, ManagedBy = "terraform" }
}

# --- Network: VPC with 3-tier subnets ---
module "network" {
  source = "../../modules/aws/network"

  project            = local.project
  environment        = local.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.tags
}

# --- Security: SGs + IAM ---
module "security" {
  source = "../../modules/aws/security"

  project     = local.project
  environment = local.environment
  vpc_id      = module.network.vpc_id
  vpc_cidr    = "10.0.0.0/16"
  tags        = local.tags
}

# --- Compute: ALB + ASG + NGINX ---
module "compute" {
  source = "../../modules/aws/compute"

  project                    = local.project
  environment                = local.environment
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  alb_security_group_id      = module.security.alb_security_group_id
  instance_security_group_id = module.security.instance_security_group_id
  instance_profile_name      = module.security.instance_profile_name
  instance_type              = "t3.micro"
  min_size                   = 1
  max_size                   = 3
  desired_capacity           = 1
  tags                       = local.tags
}

# --- Monitoring: CloudWatch alarms + dashboard ---
module "monitoring" {
  source = "../../modules/aws/monitoring"

  project        = local.project
  environment    = local.environment
  alb_arn_suffix = module.compute.alb_arn
  asg_name       = module.compute.asg_name
  alarm_email    = var.alarm_email
  tags           = local.tags
}

variable "alarm_email" {
  type    = string
  default = ""
}

output "alb_url" {
  value = "https://${module.compute.alb_dns_name}/health"
}

output "vpc_id" {
  value = module.network.vpc_id
}
