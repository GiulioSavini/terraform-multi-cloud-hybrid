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

variable "domain_name" {
  description = "Public domain the workload is published under."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.domain_name))
    error_message = "domain_name must be a valid lowercase DNS name, e.g. app.example.com."
  }
}

variable "endpoints" {
  description = "The `endpoints` output of the workload-hosting context. Records are created from these; this context does not reach into compute."
  type        = any
}

variable "networks" {
  description = "The `networks` output of the networking context. Needed to bind the Azure private zone to its VNet."
  type        = any
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      resource_group_name = string
    }))
    gcp = optional(object({
      project_id = string
    }))
  })
  default = {}
}

variable "create_public_zone" {
  description = "Create the public hosted zone. Set false when the zone is delegated from an existing registrar account."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
