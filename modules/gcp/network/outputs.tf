output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main.self_link
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = google_compute_subnetwork.web.id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = google_compute_subnetwork.app.id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = google_compute_subnetwork.data.id
}

output "web_subnet_self_link" {
  description = "Self link of the web subnet"
  value       = google_compute_subnetwork.web.self_link
}
