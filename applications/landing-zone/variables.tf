variable "landing_zone" {
  description = "Landing zone identifier, e.g. \"hybrid\"."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds this landing zone spans."
  type        = list(string)
  default     = ["aws", "azure", "gcp"]
}

# --- Ownership: mandatory, and deliberately not defaulted ---------------------

variable "owner" {
  description = "Team accountable for this landing zone."
  type        = string
}

variable "cost_center" {
  description = "Cost center billed for this landing zone."
  type        = string
}

variable "data_classification" {
  description = "Highest classification of data the landing zone may hold."
  type        = string
}

# --- Placement ----------------------------------------------------------------

variable "aws_availability_zones" {
  description = "AWS availability zones for the fabric."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "azure_location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "azure_tenant_id" {
  description = "Azure tenant id, for Key Vault access policies."
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "GCP project id."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}

# --- Fabric -------------------------------------------------------------------

variable "address_space" {
  description = "Non-overlapping CIDR per cloud."
  type = object({
    aws   = optional(string, "10.0.0.0/16")
    azure = optional(string, "10.1.0.0/16")
    gcp   = optional(string, "10.2.0.0/16")
  })
  default = {}
}

variable "enable_cross_cloud_connectivity" {
  description = "Establish IPsec tunnels between AWS and Azure."
  type        = bool
  default     = false
}

variable "cross_cloud_shared_key" {
  description = "Pre-shared key for the cross-cloud tunnels. Supply from a secret store, never from a committed tfvars file."
  type        = string
  default     = ""
  sensitive   = true
}

variable "flow_log_storage_account_id" {
  description = "Azure storage account receiving NSG flow logs."
  type        = string
  default     = ""
}

# --- Workload -----------------------------------------------------------------

variable "capacity" {
  description = "Instance count for the workload, expressed once for every cloud."
  type = object({
    min     = number
    desired = number
    max     = number
  })
  default = {
    min     = 2
    desired = 2
    max     = 6
  }
}

variable "instance_size" {
  description = "Machine size per cloud."
  type = object({
    aws   = optional(string, "t3.medium")
    azure = optional(string, "Standard_B2s")
    gcp   = optional(string, "e2-medium")
  })
  default = {}
}

variable "aws_ami_id" {
  description = "AMI for the AWS launch template. Empty uses the adapter's lookup."
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "ACM certificate for the AWS listener. Required in prd."
  type        = string
  default     = ""
}

variable "alb_ingress_cidrs" {
  description = "CIDRs allowed to reach the public load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- Service discovery and observability --------------------------------------

variable "domain_name" {
  description = "Public domain the workload is published under."
  type        = string
}

variable "create_public_zone" {
  description = "Create the public hosted zone, or attach to a delegated one."
  type        = bool
  default     = true
}

variable "alarm_email" {
  description = "Address alarms are delivered to."
  type        = string
}

variable "retention_days" {
  description = "Log retention in days."
  type        = number
  default     = 365
}

variable "enable_central_logging" {
  description = "Aggregate Azure and GCP logs into one archive."
  type        = bool
  default     = false
}
