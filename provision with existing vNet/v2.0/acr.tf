# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = var.container_registry_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = false
  lifecycle {
    ignore_changes = [tags]

  }

}

# Private Endpoint for Container Registry
resource "azurerm_private_endpoint" "acr_endpoint" {
  name                = "${var.container_registry_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet.id
  private_service_connection {
    name                           = "acrConnection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
  depends_on = [azurerm_container_registry.acr]

  private_dns_zone_group {
    name                 = "acrdnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.acr_dns_zone.id]
  }
  
  lifecycle {
    ignore_changes = [tags]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "acr_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.azurecr.io"
  resource_group_name = var.pvt_dns_rg_name
}
