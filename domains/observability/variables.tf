variable "landing_zone" {
  description = "Landing zone identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds in scope."
  type        = list(string)
}

variable "workload_refs" {
  description = "The `workload_refs` output of the workload-hosting context. Alarms attach to these handles."
  type        = any
}

variable "endpoints" {
  description = "The `endpoints` output of the workload-hosting context, for uptime checks."
  type        = any
  default     = {}
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
    }))
    gcp = optional(object({
      project_id = string
    }))
  })
  default = {}
}

variable "alarm_email" {
  description = "Address alarms are delivered to. A landing zone whose alarms go nowhere provides no detection capability."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email))
    error_message = "alarm_email must be a valid email address."
  }
}

variable "retention_days" {
  description = <<-EOT
    Log retention in days. NIS2 and ISO 27001 A.8.15 expect logs to outlive
    the detection window for an incident; 90 days is the floor enforced below.
  EOT
  type        = number
  default     = 365

  validation {
    condition     = var.retention_days >= 90
    error_message = "retention_days must be at least 90. Shorter retention leaves no evidence for an incident discovered after the fact."
  }
}

variable "enable_central_logging" {
  description = "Aggregate logs from every cloud into one archive. Requires azure and gcp both in scope."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key encrypting AWS log groups. Empty uses the CloudWatch default key."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
