# ------------------------------------------------------------------------------
# Bounded context: workload-hosting
#
# Owns the compute that serves the application: load balancers, autoscaling
# groups and the images they run. It consumes the fabric from networking and
# the identity and perimeter from access-control, and creates neither.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks."
    }
    precondition {
      condition     = !local.aws_enabled || can(var.workload_identity["aws"].instance_profile_name)
      error_message = "workload_identity.aws is required when aws is in scope. Instances must not run with an implicit role."
    }
    precondition {
      condition     = !local.gcp_enabled || can(var.workload_identity["gcp"].service_account_email)
      error_message = "workload_identity.gcp is required when gcp is in scope."
    }
    precondition {
      condition     = !local.gcp_enabled || var.gcp_self_links != null
      error_message = "gcp_self_links is required when gcp is in scope; the GCP compute API addresses networks by self link, not id."
    }
    precondition {
      condition     = var.environment != "prd" || length(var.ssl_certificate_arn) > 0 || !local.aws_enabled
      error_message = "ssl_certificate_arn is required in prd when aws is in scope. Serving production traffic over plain HTTP fails ISO 27001 A.8.24 and SOC 2 CC6.7."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project     = var.landing_zone
  environment = var.environment

  vpc_id             = var.networks["aws"].id
  public_subnet_ids  = var.networks["aws"].subnets.web
  private_subnet_ids = var.networks["aws"].subnets.app

  alb_security_group_id      = var.perimeter["aws"].alb_security_group_id
  instance_security_group_id = var.perimeter["aws"].instance_security_group_id
  instance_profile_name      = var.workload_identity["aws"].instance_profile_name

  instance_type       = var.instance_size.aws
  ami_id              = var.aws_ami_id
  min_size            = var.capacity.min
  desired_capacity    = var.capacity.desired
  max_size            = var.capacity.max
  ssl_certificate_arn = var.ssl_certificate_arn

  tags = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project     = var.landing_zone
  environment = var.environment

  resource_group_name = var.placement.azure.resource_group_name
  location            = var.placement.azure.location
  web_subnet_id       = var.networks["azure"].subnets.web[0]
  app_subnet_id       = var.networks["azure"].subnets.app[0]

  vm_sku         = var.instance_size.azure
  instance_count = var.capacity.desired
  min_instances  = var.capacity.min
  max_instances  = var.capacity.max

  tags = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project     = var.landing_zone
  environment = var.environment

  gcp_project_id    = var.placement.gcp.project_id
  region            = var.placement.gcp.region
  network_self_link = var.gcp_self_links.network
  subnet_self_link  = var.gcp_self_links.web_subnet

  service_account_email = var.workload_identity["gcp"].service_account_email

  machine_type = var.instance_size.gcp
  min_replicas = var.capacity.min
  max_replicas = var.capacity.max
  domain_name  = var.domain_name

  labels = var.labels

  depends_on = [terraform_data.guards]
}
