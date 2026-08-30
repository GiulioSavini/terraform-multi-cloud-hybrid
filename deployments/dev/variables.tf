variable "aws_region" {
  description = "AWS region for this deployment."
  type        = string
  default     = "eu-west-1"
}

variable "azure_subscription_id" {
  description = "Azure subscription id."
  type        = string
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure tenant id."
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

variable "environment" {
  description = "Environment name. Fixed per deployment directory; declared so providers can branch on it."
  type        = string
}

variable "owner" {
  description = "Team accountable for this deployment."
  type        = string
}

variable "cost_center" {
  description = "Cost center billed for this deployment."
  type        = string
}

variable "data_classification" {
  description = "Highest classification of data held here."
  type        = string
}

variable "domain_name" {
  description = "Public domain the workload is published under."
  type        = string
}

variable "alarm_email" {
  description = "Address alarms are delivered to."
  type        = string
}

variable "cross_cloud_shared_key" {
  description = "Pre-shared key for cross-cloud tunnels. Inject from a secret store; never commit it."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssl_certificate_arn" {
  description = "ACM certificate ARN for the public listener."
  type        = string
  default     = ""
}

variable "flow_log_storage_account_id" {
  description = "Azure storage account receiving NSG flow logs."
  type        = string
  default     = ""
}
