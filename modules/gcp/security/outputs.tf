output "compute_service_account_email" {
  description = "Email of the compute service account"
  value       = google_service_account.compute.email
}

output "security_policy_id" {
  description = "ID of the Cloud Armor security policy"
  value       = google_compute_security_policy.main.id
}

output "security_policy_self_link" {
  description = "Self-link of the Cloud Armor security policy"
  value       = google_compute_security_policy.main.self_link
}
