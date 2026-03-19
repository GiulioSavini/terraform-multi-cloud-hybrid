variable "project" {
  type    = string
  default = "hybrid-lz"
}

variable "environment" {
  type    = string
  default = "stg"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_location" {
  type    = string
  default = "westeurope"
}

variable "azure_tenant_id" {
  type = string
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west1"
}

variable "domain_name" {
  type    = string
  default = "hybrid.example.com"
}

variable "alarm_email" {
  type    = string
  default = ""
}

variable "enable_cross_cloud_vpn" {
  type    = bool
  default = false
}

variable "vpn_shared_key" {
  type      = string
  default   = ""
  sensitive = true
}
