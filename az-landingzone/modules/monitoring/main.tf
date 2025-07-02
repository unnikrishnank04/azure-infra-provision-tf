# Resource group for monitoring infrastructure
resource "azurerm_resource_group" "monitoring" {
  name     = "${var.prefix}-monitoring-rg"
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Action Group for alerts (email notification)
resource "azurerm_monitor_action_group" "alertgroup" {
  name                = "${var.prefix}-actgroup"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "actgrp"

  email_receiver {
    name           = "AdminEmail"
    email_address  = var.admin_email
  }
}
