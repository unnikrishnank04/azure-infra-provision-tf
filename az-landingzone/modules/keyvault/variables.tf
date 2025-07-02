variable "prefix" {
  description = "Name prefix for Key Vault resources"
}
variable "location" {
  description = "Azure region"
}
variable "tags" {
  description = "Tags to apply to Key Vault resources"
  type        = map(string)
}

output "key_vault_uri" {
  description = "Vault URI for applications to retrieve secrets"
  value       = azurerm_key_vault.vault.vault_uri
}
