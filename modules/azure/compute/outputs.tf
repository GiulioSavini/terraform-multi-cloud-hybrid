output "vmss_id" {
  description = "ID of the VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

output "lb_public_ip" {
  description = "Public IP of the Load Balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "lb_id" {
  description = "ID of the Load Balancer"
  value       = azurerm_lb.main.id
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = azurerm_user_assigned_identity.vmss.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.vmss.principal_id
}
