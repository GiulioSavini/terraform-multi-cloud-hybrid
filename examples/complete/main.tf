# =============================================================================
# Complete Multi-Cloud Hybrid Landing Zone Example
# Deploys the full stack: AWS + Azure + GCP with cross-cloud VPN and logging
# =============================================================================
#
# Usage:
#   cp terraform.tfvars.example terraform.tfvars
#   # Edit terraform.tfvars with your values
#   terraform init
#   terraform plan -out=tfplan
#   terraform apply tfplan
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - Azure CLI logged in (az login)
#   - GCP CLI authenticated (gcloud auth application-default login)
#   - Terraform >= 1.9.0
#
# Estimated cost: ~$150/month (dev sizing)
# Deploy time: ~15-20 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    google  = { source = "hashicorp/google", version = "~> 5.0" }
    tls     = { source = "hashicorp/tls", version = "~> 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------
locals {
  project     = "hybrid-example"
  environment = "dev"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    Example     = "complete"
  }
}

# -----------------------------------------------------------------------------
# Azure Resource Group (required by Azure modules)
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.azure_location
  tags     = local.common_tags
}

# =============================================================================
# AWS Modules
# =============================================================================

module "aws_network" {
  source = "../../modules/aws/network"

  project            = local.project
  environment        = local.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  enable_nat_gateway = true
  single_nat_gateway = true # Cost saving for dev
  enable_vpn_gateway = false
  tags               = local.common_tags
}

module "aws_security" {
  source = "../../modules/aws/security"

  project     = local.project
  environment = local.environment
  vpc_id      = module.aws_network.vpc_id
  vpc_cidr    = "10.0.0.0/16"
  tags        = local.common_tags
}

module "aws_compute" {
  source = "../../modules/aws/compute"

  project                    = local.project
  environment                = local.environment
  vpc_id                     = module.aws_network.vpc_id
  public_subnet_ids          = module.aws_network.public_subnet_ids
  private_subnet_ids         = module.aws_network.private_subnet_ids
  alb_security_group_id      = module.aws_security.alb_security_group_id
  instance_security_group_id = module.aws_security.instance_security_group_id
  instance_profile_name      = module.aws_security.instance_profile_name
  instance_type              = "t3.micro"
  min_size                   = 1
  max_size                   = 2
  desired_capacity           = 1
  tags                       = local.common_tags
}

module "aws_monitoring" {
  source = "../../modules/aws/monitoring"

  project        = local.project
  environment    = local.environment
  alb_arn_suffix = module.aws_compute.alb_arn
  asg_name       = module.aws_compute.asg_name
  alarm_email    = var.alarm_email
  tags           = local.common_tags
}

# =============================================================================
# Azure Modules
# =============================================================================

module "azure_network" {
  source = "../../modules/azure/network"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vnet_cidr           = "10.1.0.0/16"
  enable_vpn_gateway  = false
  tags                = local.common_tags
}

module "azure_compute" {
  source = "../../modules/azure/compute"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  app_subnet_id       = module.azure_network.app_subnet_id
  web_subnet_id       = module.azure_network.web_subnet_id
  vm_sku              = "Standard_B1s"
  instance_count      = 1
  min_instances       = 1
  max_instances       = 2
  tags                = local.common_tags
}

module "azure_monitoring" {
  source = "../../modules/azure/monitoring"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vmss_id             = module.azure_compute.vmss_id
  alarm_email         = var.alarm_email
  tags                = local.common_tags
}

# =============================================================================
# GCP Modules
# =============================================================================

module "gcp_network" {
  source = "../../modules/gcp/network"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
  labels         = local.common_tags
}

module "gcp_security" {
  source = "../../modules/gcp/security"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.common_tags
}

module "gcp_compute" {
  source = "../../modules/gcp/compute"

  project               = local.project
  environment           = local.environment
  gcp_project_id        = var.gcp_project_id
  region                = var.gcp_region
  network_self_link     = module.gcp_network.network_self_link
  subnet_self_link      = module.gcp_network.web_subnet_self_link
  machine_type          = "e2-micro"
  min_replicas          = 1
  max_replicas          = 2
  service_account_email = module.gcp_security.compute_service_account_email
  labels                = local.common_tags
}

# =============================================================================
# Cross-Cloud Centralized Logging
# =============================================================================

module "cross_cloud_logging" {
  source = "../../modules/cross-cloud/logging"

  project                          = local.project
  environment                      = local.environment
  gcp_project_id                   = var.gcp_project_id
  azure_resource_group_name        = azurerm_resource_group.main.name
  azure_location                   = var.azure_location
  azure_log_analytics_workspace_id = module.azure_monitoring.log_analytics_workspace_id
  retention_days                   = 30
  tags                             = local.common_tags
}

# =============================================================================
# Outputs
# =============================================================================

output "aws_alb_url" {
  description = "AWS ALB URL - test with: curl -k https://<url>/health"
  value       = "https://${module.aws_compute.alb_dns_name}"
}

output "azure_lb_ip" {
  description = "Azure LB IP - test with: curl -k https://<ip>/health"
  value       = module.azure_compute.lb_public_ip
}

output "gcp_lb_ip" {
  description = "GCP LB IP - test with: curl -k https://<ip>/health"
  value       = module.gcp_compute.lb_ip_address
}
