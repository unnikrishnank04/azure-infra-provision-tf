# Cognitive Search Service
resource "azurerm_search_service" "search_service" {
  name                          = var.search_service_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "standard"
  public_network_access_enabled = false
  replica_count                 = 1
  partition_count               = 1
  lifecycle {
    ignore_changes = [tags]

  }
}

# Private Endpoint for Search Service
resource "azurerm_private_endpoint" "search_endpoint" {
  name                = "${var.search_service_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet_03.id
  private_service_connection {
    name                           = "searchConnection"
    private_connection_resource_id = azurerm_search_service.search_service.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }
  # Creating DNS entry of this private link private IP address to Private DNS Zone
  private_dns_zone_group {
    name                 = "azsearchzone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.search_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]

  }
  depends_on = [azurerm_search_service.search_service]
}

# Fetch a Private DNS zone for Search
data "azurerm_private_dns_zone" "search_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.search.windows.net"
  resource_group_name = var.pvt_dns_rg_name
}
