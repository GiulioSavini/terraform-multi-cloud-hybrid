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

variable "location" {
  description = "Azure region"
  type        = string
}

variable "app_subnet_id" {
  description = "Subnet ID for VMSS"
  type        = string
}

variable "web_subnet_id" {
  description = "Subnet ID for Load Balancer"
  type        = string
}

variable "vm_sku" {
  description = "VM SKU for the scale set"
  type        = string
  default     = "Standard_B2s"
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "min_instances" {
  description = "Minimum instances for autoscale"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum instances for autoscale"
  type        = number
  default     = 5
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
