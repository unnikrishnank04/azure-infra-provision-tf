variable "prefix" {
  description = "Name prefix for all monitoring resources"
}
variable "location" {
  description = "Azure region"
}
variable "admin_email" {
  description = "Email address for alert notifications"
}
variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}
