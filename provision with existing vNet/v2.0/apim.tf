data "azurerm_subnet" "apim_subnet" {
  name                 = var.apim_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}


# Create Application Insights and link to Log Analytics Workspace
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.apim_name}-appinsights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  application_type    = "web"

  # Link Application Insights to Log Analytics Workspace
  workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  depends_on   = [azurerm_log_analytics_workspace.log_analytics]

  lifecycle {
    ignore_changes = [tags]
  }

}

# API Management (APIM)
resource "azurerm_api_management" "apim" {
  name                 = var.apim_name
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  publisher_name       = var.apim_publisher_name
  publisher_email      = var.apim_publisher_email
  sku_name             = var.apim_sku_detail
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.apim_subnet.id
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    ProvisionedVia = "Terraform"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

