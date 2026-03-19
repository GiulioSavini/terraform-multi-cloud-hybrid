locals {
  environment = basename(path_relative_to_include())
  project     = "hybrid-landing-zone"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    Repository  = "terraform-multi-cloud-hybrid"
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend_generated.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.project}-tfstate-${local.environment}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "${local.project}-tflock-${local.environment}"
  }
}

generate "providers" {
  path      = "providers_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.9.0"
    }
  EOF
}

inputs = {
  project     = local.project
  environment = local.environment
  common_tags = local.common_tags
}
