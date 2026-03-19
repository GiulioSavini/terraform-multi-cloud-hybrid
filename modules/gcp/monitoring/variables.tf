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

variable "notification_email" {
  description = "Email for alert notifications"
  type        = string
  default     = ""
}

variable "lb_ip_address" {
  description = "Load balancer IP for uptime checks"
  type        = string
  default     = ""
}

variable "instance_group_name" {
  description = "MIG name for monitoring"
  type        = string
  default     = ""
}
