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

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "web_subnet_cidr" {
  description = "CIDR for web subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "app_subnet_cidr" {
  description = "CIDR for app subnet"
  type        = string
  default     = "10.2.2.0/24"
}

variable "data_subnet_cidr" {
  description = "CIDR for data subnet"
  type        = string
  default     = "10.2.3.0/24"
}

variable "enable_cloud_nat" {
  description = "Enable Cloud NAT"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Common labels"
  type        = map(string)
  default     = {}
}
