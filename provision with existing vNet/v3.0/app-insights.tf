# Application Insights
resource "azurerm_application_insights" "app_insights" {
  for_each            = toset(var.app_insights_name)
  name                = each.value
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"

  lifecycle {
    ignore_changes = [tags]

  }

  depends_on = [azurerm_log_analytics_workspace.log_analytics]
}

# Application Insights for web app
resource "azurerm_application_insights" "webapp_insights" {
  for_each            = toset(var.webapp_insights_name)
  name                = each.value
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"

  lifecycle {
    ignore_changes = [tags]

  }

  depends_on = [azurerm_log_analytics_workspace.log_analytics]
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  lifecycle {
    ignore_changes = [tags]

  }

}
