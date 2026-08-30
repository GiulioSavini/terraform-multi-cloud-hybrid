variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "aws_vpn_gateway_id" {
  description = "AWS VPN Gateway ID"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
}

variable "azure_vpn_gateway_id" {
  description = "Azure VPN Gateway ID"
  type        = string
}

variable "azure_vpn_gateway_public_ip" {
  description = "Azure VPN Gateway public IP"
  type        = string
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR"
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

variable "shared_key" {
  description = "Pre-shared key for VPN (use secrets manager in production)"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
