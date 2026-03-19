output "zone_name" {
  description = "Name of the DNS zone"
  value       = google_dns_managed_zone.main.name
}

output "name_servers" {
  description = "Name servers for the zone"
  value       = google_dns_managed_zone.main.name_servers
}

output "app_fqdn" {
  description = "FQDN of the app record"
  value       = google_dns_record_set.app.name
}
