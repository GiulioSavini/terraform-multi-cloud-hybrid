variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "alb_ingress_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the ALB on 80/443. Defaults to the public
    internet, which is the point of a public ALB — narrow it to office or
    CDN ranges when the service is not meant to be world-reachable.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.alb_ingress_cidrs) > 0
    error_message = "alb_ingress_cidrs must contain at least one CIDR block."
  }
}
