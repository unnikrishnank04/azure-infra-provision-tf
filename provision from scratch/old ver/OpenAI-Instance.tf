#OpenAI Instances with Private Endpoint
resource "azurerm_cognitive_account" "OpenAI-Instance1" {
  name                = var.OpenAI_Instance[0] #"OpenAI-Instance1"
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  sku_name            = "S0"
  kind                = "OpenAI"
  custom_subdomain_name = "openaiinstance-${var.environment}"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub3 ]
}

#Model deployment:
resource "azurerm_cognitive_deployment" "openai_deployment" {
  #provider             = azurerm.account_oai  
  name                 = "gpt-4-mini-deployment"
  cognitive_account_id = azurerm_cognitive_account.OpenAI-Instance1.id
  depends_on = [ azurerm_cognitive_account.OpenAI-Instance1 ]
  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "1"
  }
  #capacity = 1
  sku {
    name = "Standard"
  }  
}

# Private Endpoint
resource "azurerm_private_endpoint" "OpenAI-Pvt-endpoint" {
  name                = "${var.OpenAI_Instance[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub3.id
  depends_on = [ azurerm_cognitive_account.OpenAI-Instance1 ]
  private_service_connection {
    name                           = "${var.OpenAI_Instance[0]}-Pvt-endpoint-connection"
    private_connection_resource_id = azurerm_cognitive_account.OpenAI-Instance1.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.gpt4o_mini_dns_zone.id]
  }
}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "gpt4o_mini_dns_zone" {
  #provider            = azurerm.account_pvt_zones
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_cognitive_account.OpenAI-Instance1 ]
}

