
#Azure AI Search Service With Private Endpoint
resource "azurerm_search_service" "searchserviceckadev" {
  name                = var.AISearch_Service[0] #"searchserviceckadev"
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  sku                 = var.AISearch_Service[1]
  partition_count     = 1
  replica_count       = 1
  depends_on = [ azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3 ]
/*
  tags = {
    environment = var.AISearch_Service[2]
  }*/
}

resource "azurerm_private_endpoint" "Search-Service-CKA-dev-Pvt-endpoint" {
  name                = "${var.AISearch_Service[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  subnet_id           = azurerm_subnet.Pvt-Sub3.id
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_search_service.searchserviceckadev ]

  private_service_connection {
    name                           = "${var.AISearch_Service[0]}-Pvt-endpoint-Connection"
    private_connection_resource_id = azurerm_search_service.searchserviceckadev.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }
   # Creating DNS entry of this private link private IP address to Private DNS Zone
  private_dns_zone_group {
    name                 = "azsearchzone"
    private_dns_zone_ids = [azurerm_private_dns_zone.search_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]

  }

}

# Fetch a Private DNS zone for Search
resource "azurerm_private_dns_zone" "search_dns_zone" {
#  provider            = azurerm.account_pvt_zones
  name                = "privatelink.search.windows.net"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}

