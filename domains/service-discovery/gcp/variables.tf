variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "domain_name" {
  description = "DNS domain name"
  type        = string
}

variable "lb_ip_address" {
  description = "Load balancer IP address"
  type        = string
}
