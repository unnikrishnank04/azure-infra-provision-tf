# WebApplication Insights
resource "azurerm_application_insights" "webapp_insights" {
  for_each = toset(var.webapp_insights_name)
  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group
  workspace_id        = azurerm_log_analytics_workspace.cka-loganalytic_workspace.id
  application_type    = "web"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_log_analytics_workspace.cka-loganalytic_workspace ]
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  for_each = toset(var.app_insights)
  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group
  workspace_id        = azurerm_log_analytics_workspace.cka-loganalytic_workspace.id
  application_type    = "web"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_log_analytics_workspace.cka-loganalytic_workspace ]
}

#Log Analytic workspace.
resource "azurerm_log_analytics_workspace" "cka-loganalytic_workspace" {
  name                = var.log_analytics_workspace
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
}