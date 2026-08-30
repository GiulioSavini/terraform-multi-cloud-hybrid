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

variable "networks" {
  description = "The `networks` output of the networking context."
  type = map(object({
    id   = string
    cidr = string
    subnets = object({
      web  = list(string)
      app  = list(string)
      data = list(string)
    })
  }))
}

variable "gcp_self_links" {
  description = "The `gcp_self_links` output of the networking context. Required when gcp is in scope."
  type = object({
    network    = string
    web_subnet = string
  })
  default = null
}

variable "workload_identity" {
  description = "The `workload_identity` output of the access-control context. Instances assume these; this context never creates identities of its own."
  type        = any
}

variable "perimeter" {
  description = "The `perimeter` output of the access-control context."
  type        = any
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
      region     = string
    }))
  })
  default = {}
}

variable "capacity" {
  description = <<-EOT
    Instance count for the workload, expressed once for every cloud. Each
    provider names these differently (ASG desired_capacity, VMSS instances,
    MIG replicas); the domain has one concept.
  EOT
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

  validation {
    condition     = var.capacity.min <= var.capacity.desired && var.capacity.desired <= var.capacity.max
    error_message = "capacity must satisfy min <= desired <= max."
  }

  validation {
    condition     = var.capacity.min >= 2
    error_message = "capacity.min must be at least 2. A single instance behind a load balancer has no availability story and fails CIS/SOC 2 resilience expectations."
  }
}

variable "instance_size" {
  description = "Machine size per cloud. Provider-specific by nature; there is no portable vocabulary for instance sizing."
  type = object({
    aws   = optional(string, "t3.medium")
    azure = optional(string, "Standard_B2s")
    gcp   = optional(string, "e2-medium")
  })
  default = {}
}

variable "aws_ami_id" {
  description = "AMI for the AWS launch template. Empty selects the adapter's default lookup."
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "ACM certificate for the AWS listener. Empty provisions HTTP only, which is acceptable in dev and not elsewhere."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Public domain for the workload, used by the GCP managed certificate."
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
