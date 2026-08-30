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

variable "azure_resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
}

variable "azure_location" {
  description = "Azure location"
  type        = string
}

variable "azure_log_analytics_workspace_id" {
  description = "Azure Log Analytics workspace ID"
  type        = string
}

variable "retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
