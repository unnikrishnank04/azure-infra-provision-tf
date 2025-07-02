
#AI Language with Private Endpoint

resource "azurerm_cognitive_account" "AILanguage_Service-CKA-dev" {
  name                = var.AILanguage_Service[0] #"AILanguage_Service-CKA-dev"
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  kind                = "TextTranslation"
  sku_name            = var.AILanguage_Service[1] #"S0"
  custom_subdomain_name = "ailanguageckadev"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3 ]
  /*
  properties {
    api_properties {
      qna_runtime_endpoint = "https://AILanguage_Service-CKA-dev.cognitiveservices.azure.com/"
    } 
  }*/
}

# Private Endpoint
resource "azurerm_private_endpoint" "AILanguage_Service-CKA-dev-Pvt-endpoint" {
  name                = "${var.AILanguage_Service[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  subnet_id           = azurerm_subnet.Pvt-Sub3.id
  depends_on = [ azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_cognitive_account.AILanguage_Service-CKA-dev]

  private_service_connection {
    name                           = "${var.AILanguage_Service[0]}-Pvt-endpoint-connection"
    private_connection_resource_id = azurerm_cognitive_account.AILanguage_Service-CKA-dev.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "aildnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.ail_dns_zone.id]
  }

}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "ail_dns_zone" {
  #provider            = azurerm.account_pvt_zones
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_cognitive_account.AILanguage_Service-CKA-dev]
}

