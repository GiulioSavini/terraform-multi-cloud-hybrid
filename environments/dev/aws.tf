# =============================================================================
# AWS Resources - Dev Environment
# =============================================================================

module "aws_network" {
  source = "../../modules/aws/network"

  project            = var.project
  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  enable_nat_gateway = true
  single_nat_gateway = true # Cost saving for dev
  enable_vpn_gateway = var.enable_cross_cloud_vpn
  tags               = local.common_tags
}

module "aws_security" {
  source = "../../modules/aws/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.aws_network.vpc_id
  vpc_cidr    = "10.0.0.0/16"
  tags        = local.common_tags
}

module "aws_compute" {
  source = "../../modules/aws/compute"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.aws_network.vpc_id
  public_subnet_ids          = module.aws_network.public_subnet_ids
  private_subnet_ids         = module.aws_network.private_subnet_ids
  alb_security_group_id      = module.aws_security.alb_security_group_id
  instance_security_group_id = module.aws_security.instance_security_group_id
  instance_profile_name      = module.aws_security.instance_profile_name
  instance_type              = "t3.micro" # Dev: small
  min_size                   = 1
  max_size                   = 2
  desired_capacity           = 1
  tags                       = local.common_tags
}

module "aws_monitoring" {
  source = "../../modules/aws/monitoring"

  project        = var.project
  environment    = var.environment
  alb_arn_suffix = module.aws_compute.alb_arn
  asg_name       = module.aws_compute.asg_name
  alarm_email    = var.alarm_email
  tags           = local.common_tags
}

module "aws_dns" {
  source = "../../modules/aws/dns"

  project      = var.project
  environment  = var.environment
  domain_name  = var.domain_name
  alb_dns_name = module.aws_compute.alb_dns_name
  alb_zone_id  = module.aws_compute.alb_zone_id
  tags         = local.common_tags
}
