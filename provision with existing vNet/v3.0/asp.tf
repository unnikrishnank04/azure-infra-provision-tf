# App Service Plan for Linux Web App
resource "azurerm_service_plan" "service_plan" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P2v3"

  lifecycle {
    ignore_changes = [tags]

  }

}

