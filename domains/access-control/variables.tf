variable "landing_zone" {
  description = "Landing zone identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds in scope. Must be a subset of the clouds the networking context provisioned."
  type        = list(string)
}

variable "networks" {
  description = "The `networks` output of the networking context. This context attaches to that fabric and does not create networks of its own."
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

variable "placement" {
  description = "Provider-specific placement. Required only for the clouds in scope."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
      tenant_id           = string
    }))
    gcp = optional(object({
      project_id = string
    }))
  })
  default = {}
}

variable "alb_ingress_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the public load balancer on 80/443. Defaults
    to the internet, which is the point of a public endpoint — narrow it when
    the service is not meant to be world-reachable.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}

