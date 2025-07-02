#Document Intelligence with Private Endpoint
resource "azurerm_cognitive_account" "Form-Recognizer-CKA-dev" {
  name                = var.Form_Recognizer[0] #"Form-Recognizer-CKA-dev"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  kind                = "FormRecognizer"
  sku_name = var.Form_Recognizer[1] #"S0"
  custom_subdomain_name = var.Form_Recognizer[2] #"formrecognizerckadem1"
  depends_on = [azurerm_resource_group.KnowledgeAssist_dev,  azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_cognitive_account.AILanguage_Service-CKA-dev ]
/*
  tags = {
    Acceptance = "Test"s
  }*/
}

# Private Endpoint
resource "azurerm_private_endpoint" "Form_Recognizer-CKA_dev-Pvt_endpoint" {
  name                = "${var.Form_Recognizer[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  subnet_id           = azurerm_subnet.Pvt-Sub4.id
  depends_on = [ azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3, azurerm_cognitive_account.Form-Recognizer-CKA-dev ]
  private_service_connection {
    name                           = "${var.Form_Recognizer[0]}-Pvt_endpoint-connection"
    private_connection_resource_id = azurerm_cognitive_account.Form-Recognizer-CKA-dev.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "doidnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.doi_dns_zone.id]
  }

}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "doi_dns_zone" {
  #provider            = azurerm.account_pvt_zones
  name                = "privatelink.cognitiveservices-doi.azure.com"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}
