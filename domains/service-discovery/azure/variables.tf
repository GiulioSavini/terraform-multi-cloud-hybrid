variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID for private DNS link"
  type        = string
}

variable "domain_name" {
  description = "Private DNS zone name"
  type        = string
  default     = "hybrid.internal"
}

variable "lb_private_ip" {
  description = "Private IP of the load balancer"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
