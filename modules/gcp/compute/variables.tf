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

variable "subnet_self_link" {
  description = "Self link of the subnet"
  type        = string
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-micro"
}

variable "min_replicas" {
  description = "Min replicas in MIG"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Max replicas in MIG"
  type        = number
  default     = 3
}

variable "service_account_email" {
  description = "Service account email for instances"
  type        = string
}

variable "labels" {
  description = "Common labels"
  type        = map(string)
  default     = {}
}

variable "kms_key_self_link" {
  description = "Self-link of the KMS key to use for disk encryption. Leave empty to skip encryption."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Base domain name used for the managed SSL certificate"
  type        = string
  default     = "hybrid.example.com"
}
