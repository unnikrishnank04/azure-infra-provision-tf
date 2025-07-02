
#Content Safety with Private Endpoint
resource "azurerm_cognitive_account" "Content-Safety-CKA-dev" {
  name                = var.Content_Safety[0] #"Content-Safety-CKA-demo1"
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  kind                = "ContentSafety"
  sku_name            = var.Content_Safety[1] #"S0"
  custom_subdomain_name = "contentsafetycka${var.environment}"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_cognitive_account.AILanguage_Service-CKA-dev ]
  /*
  properties {
    api_properties {
      qna_runtime_endpoint = "https://Content-Safety-CKA-demo1.cognitiveservices.azure.com/"
    }
  } */
}


# Private Endpoint
resource "azurerm_private_endpoint" "Content-Safety-CKA-dev-Pvt-endpoint" {
  name                = "${var.Content_Safety[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub3.id
  depends_on = [ azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_cognitive_account.Content-Safety-CKA-dev]
  private_service_connection {
    name                           = "${var.Content_Safety[0]}-Pvt-endpoint"
    private_connection_resource_id = azurerm_cognitive_account.Content-Safety-CKA-dev.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "cosdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.cos_dns_zone.id]
  }

}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "cos_dns_zone" {
 # provider            = azurerm.account_pvt_zones
  name                = "privatelink.cognitiveservices-cos.azure.com"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}

