variable "project" {
  description = "Project name"
  type        = string
  default     = "hybrid-lz"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "stg"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
  default     = "hybrid.example.com"
}

variable "alarm_email" {
  description = "Email for alarm notifications"
  type        = string
  default     = ""
}

variable "enable_cross_cloud_vpn" {
  description = "Enable cross-cloud VPN connectivity"
  type        = bool
  default     = false
}

variable "vpn_shared_key" {
  description = "Pre-shared key for VPN connections"
  type        = string
  default     = ""
  sensitive   = true
}
