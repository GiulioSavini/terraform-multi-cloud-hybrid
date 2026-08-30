variable "landing_zone" {
  description = "Landing zone identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds that participate in this network fabric."
  type        = list(string)

  validation {
    condition     = length(var.clouds) > 0 && length(setsubtract(toset(var.clouds), toset(["aws", "azure", "gcp"]))) == 0
    error_message = "clouds must be a non-empty subset of: aws, azure, gcp."
  }
}

variable "address_space" {
  description = <<-EOT
    CIDR allocated to each participating cloud. Ranges must not overlap: the
    cross-cloud tunnels route between them, and overlapping ranges produce a
    fabric that builds cleanly and blackholes traffic at runtime.
  EOT
  type = object({
    aws   = optional(string, "10.0.0.0/16")
    azure = optional(string, "10.1.0.0/16")
    gcp   = optional(string, "10.2.0.0/16")
  })
  default = {}
}

variable "placement" {
  description = "Provider-specific placement. Required only for the clouds listed in var.clouds."
  type = object({
    aws = optional(object({
      availability_zones = list(string)
    }))
    azure = optional(object({
      location            = string
      resource_group_name = string
    }))
    gcp = optional(object({
      project_id = string
      region     = string
    }))
  })
}

variable "enable_cross_cloud_connectivity" {
  description = "Establish IPsec tunnels between the participating clouds. Requires aws and azure to both be present."
  type        = bool
  default     = false
}

variable "cross_cloud_shared_key" {
  description = "Pre-shared key for the cross-cloud IPsec tunnels. Supply from a secret store, never a tfvars file committed to the repo."
  type        = string
  default     = ""
  sensitive   = true
}

variable "flow_logs_enabled" {
  description = <<-EOT
    Enable network flow logging. Required evidence for CIS 3.x, ISO 27001
    A.8.15/A.8.16 and NIS2 incident detection; leave it on unless a specific
    exception is recorded in compliance/controls.
  EOT
  type        = bool
  default     = true
}

variable "flow_log_storage_account_id" {
  description = "Azure storage account receiving NSG flow logs. Required when flow_logs_enabled and azure is in scope."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}

variable "labels" {
  description = "GCP-normalised label set from platform/tagging."
  type        = map(string)
  default     = {}
}
