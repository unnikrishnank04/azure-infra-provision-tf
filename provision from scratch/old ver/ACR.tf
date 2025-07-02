#ACR - Container Registry
resource "azurerm_container_registry" "ACR-dev" {
  name                     = var.container_registry_name #"acrdemo14"
  location                 = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name      = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  sku                      = var.container_registry_sku[2]
  admin_enabled            = true
  #custom_subdomain_name = "https://eastus.api.cognitive.microsoft.com/"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub1, azurerm_linux_web_app.app_service ]
}

resource "azurerm_private_endpoint" "acrckadev-private-endpoint" {
  name                = "${var.container_registry_name}-private-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub1.id
  depends_on = [ azurerm_container_registry.ACR-dev, azurerm_linux_web_app.app_service]

  private_service_connection {
    name                           = "${var.container_registry_name}-privatesc"
    private_connection_resource_id = azurerm_container_registry.ACR-dev.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }  

  private_dns_zone_group {
    name                 = "acrdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_dns_zone.id]
  }
}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "acr_dns_zone" {
 # provider            = azurerm.account_pvt_zones 
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_linux_web_app.app_service ]
}
