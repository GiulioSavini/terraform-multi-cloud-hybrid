output "lb_ip_address" {
  description = "External IP of the load balancer"
  value       = google_compute_global_address.main.address
}

output "instance_group" {
  description = "Instance group URL"
  value       = google_compute_region_instance_group_manager.main.instance_group
}

output "backend_service_id" {
  description = "ID of the backend service"
  value       = google_compute_backend_service.main.id
}
