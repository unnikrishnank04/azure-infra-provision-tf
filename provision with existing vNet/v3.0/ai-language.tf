# Language
resource "azurerm_cognitive_account" "language" {
  name                          = var.language_account_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  kind                          = "TextAnalytics"
  sku_name                      = "S"
  public_network_access_enabled = false
  custom_subdomain_name         = var.language_account_name

  lifecycle {
    ignore_changes = [tags]

  }
  identity {
    type = "SystemAssigned"
  }

}

# Private Endpoint for Language
resource "azurerm_private_endpoint" "language_pvt_ep" {
  name                = "${var.language_account_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet.id
  private_service_connection {
    name                           = "openaiConnection"
    private_connection_resource_id = azurerm_cognitive_account.language.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "aildnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.ail_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "ail_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = var.pvt_dns_rg_name
}
