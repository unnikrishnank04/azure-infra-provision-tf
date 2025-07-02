resource "azurerm_cognitive_account" "oai_north_cen_us" {
  provider                      = azurerm.account_oai
  name                          = var.oai_resource_name_north_central_us
  location                      = "northcentralus"
  resource_group_name           = azurerm_resource_group.oai_rg.name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  custom_subdomain_name         = var.oai_resource_name_north_central_us
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [tags]

  }

}

resource "azurerm_cognitive_deployment" "oai_north_cen_us_model_deployment" {
  provider               = azurerm.account_oai
  name                   = "gpt-35-turbo"
  cognitive_account_id   = azurerm_cognitive_account.oai_north_cen_us.id
  rai_policy_name        = "Microsoft.DefaultV2"
  version_upgrade_option = "OnceCurrentVersionExpired"
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0125"
  }
  sku {
    name = "Standard"
    capacity = "300" # in K TPMs

  }
}

resource "azurerm_cognitive_deployment" "oai_north_cen_us_model_deployment_ada" {
  provider               = azurerm.account_oai
  name                   = "text-embedding-ada-002"
  cognitive_account_id   = azurerm_cognitive_account.oai_north_cen_us.id
  rai_policy_name        = "Microsoft.DefaultV2"
  version_upgrade_option = "OnceCurrentVersionExpired"
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "2"
  }
  sku {
    name = "Standard"
    capacity = "350" # in K TPMs
  }
}

# Private Endpoint for Open AI 1
resource "azurerm_private_endpoint" "oai_north_cen_us_ep" {
  name                = "${var.oai_resource_name_north_central_us}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet_03.id
  private_service_connection {
    name                           = "openaiConnection"
    private_connection_resource_id = azurerm_cognitive_account.oai_north_cen_us.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.oai_north_cen_us_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]

  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "oai_north_cen_us_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.pvt_dns_rg_name
}
