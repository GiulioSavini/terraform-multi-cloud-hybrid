locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = "infrastructure"
    Repository  = "terraform-multi-cloud-hybrid"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.azure_location
  tags     = local.common_tags
}

# --- AWS (Production: HA, multi-AZ) ---
module "aws_network" {
  source             = "../../modules/aws/network"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  enable_nat_gateway = true
  single_nat_gateway = false # HA: one NAT per AZ
  enable_vpn_gateway = var.enable_cross_cloud_vpn
  tags               = local.common_tags
}

module "aws_security" {
  source      = "../../modules/aws/security"
  project     = var.project
  environment = var.environment
  vpc_id      = module.aws_network.vpc_id
  vpc_cidr    = "10.0.0.0/16"
  tags        = local.common_tags
}

module "aws_compute" {
  source                     = "../../modules/aws/compute"
  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.aws_network.vpc_id
  public_subnet_ids          = module.aws_network.public_subnet_ids
  private_subnet_ids         = module.aws_network.private_subnet_ids
  alb_security_group_id      = module.aws_security.alb_security_group_id
  instance_security_group_id = module.aws_security.instance_security_group_id
  instance_profile_name      = module.aws_security.instance_profile_name
  instance_type              = "t3.medium" # Prd: larger
  min_size                   = 3
  max_size                   = 10
  desired_capacity           = 3
  tags                       = local.common_tags
}

module "aws_monitoring" {
  source         = "../../modules/aws/monitoring"
  project        = var.project
  environment    = var.environment
  alb_arn_suffix = module.aws_compute.alb_arn
  asg_name       = module.aws_compute.asg_name
  alarm_email    = var.alarm_email
  tags           = local.common_tags
}

module "aws_dns" {
  source       = "../../modules/aws/dns"
  project      = var.project
  environment  = var.environment
  domain_name  = var.domain_name
  alb_dns_name = module.aws_compute.alb_dns_name
  alb_zone_id  = module.aws_compute.alb_zone_id
  tags         = local.common_tags
}

# --- Azure (Production: HA, zone-balanced) ---
module "azure_network" {
  source              = "../../modules/azure/network"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vnet_cidr           = "10.1.0.0/16"
  enable_vpn_gateway  = var.enable_cross_cloud_vpn
  tags                = local.common_tags
}

module "azure_compute" {
  source              = "../../modules/azure/compute"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  app_subnet_id       = module.azure_network.app_subnet_id
  web_subnet_id       = module.azure_network.web_subnet_id
  vm_sku              = "Standard_D2s_v5" # Prd: larger
  instance_count      = 3
  min_instances       = 3
  max_instances       = 10
  tags                = local.common_tags
}

module "azure_security" {
  source              = "../../modules/azure/security"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  tenant_id           = var.azure_tenant_id
  tags                = local.common_tags
}

module "azure_monitoring" {
  source              = "../../modules/azure/monitoring"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  vmss_id             = module.azure_compute.vmss_id
  alarm_email         = var.alarm_email
  tags                = local.common_tags
}

module "azure_dns" {
  source              = "../../modules/azure/dns"
  project             = var.project
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.azure_network.vnet_id
  tags                = local.common_tags
}

# --- GCP (Production: HA) ---
module "gcp_network" {
  source         = "../../modules/gcp/network"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
  labels         = local.common_tags
}

module "gcp_security" {
  source         = "../../modules/gcp/security"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.common_tags
}

module "gcp_compute" {
  source                = "../../modules/gcp/compute"
  project               = var.project
  environment           = var.environment
  gcp_project_id        = var.gcp_project_id
  region                = var.gcp_region
  network_self_link     = module.gcp_network.network_self_link
  subnet_self_link      = module.gcp_network.web_subnet_self_link
  machine_type          = "e2-standard-2" # Prd: larger
  min_replicas          = 3
  max_replicas          = 10
  service_account_email = module.gcp_security.compute_service_account_email
  labels                = local.common_tags
}

module "gcp_monitoring" {
  source             = "../../modules/gcp/monitoring"
  project            = var.project
  environment        = var.environment
  gcp_project_id     = var.gcp_project_id
  notification_email = var.alarm_email
  lb_ip_address      = module.gcp_compute.lb_ip_address
}

module "gcp_dns" {
  source         = "../../modules/gcp/dns"
  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  domain_name    = var.domain_name
  lb_ip_address  = module.gcp_compute.lb_ip_address
}

# --- Cross-Cloud ---
module "cross_cloud_logging" {
  source                           = "../../modules/cross-cloud/logging"
  project                          = var.project
  environment                      = var.environment
  gcp_project_id                   = var.gcp_project_id
  azure_resource_group_name        = azurerm_resource_group.main.name
  azure_location                   = var.azure_location
  azure_log_analytics_workspace_id = module.azure_monitoring.log_analytics_workspace_id
  retention_days                   = 90
  tags                             = local.common_tags
}

module "cross_cloud_vpn" {
  source = "../../modules/cross-cloud/vpn"
  count  = var.enable_cross_cloud_vpn ? 1 : 0

  project                     = var.project
  environment                 = var.environment
  aws_vpn_gateway_id          = module.aws_network.vpn_gateway_id
  aws_vpc_cidr                = "10.0.0.0/16"
  azure_vpn_gateway_id        = module.azure_network.vpn_gateway_id
  azure_vpn_gateway_public_ip = module.azure_network.vpn_gateway_public_ip
  azure_vnet_cidr             = "10.1.0.0/16"
  azure_resource_group_name   = azurerm_resource_group.main.name
  azure_location              = var.azure_location
  shared_key                  = var.vpn_shared_key
  tags                        = local.common_tags
}
