output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "security_logs_storage_id" {
  description = "ID of the security logs storage account"
  value       = azurerm_storage_account.security_logs.id
}
