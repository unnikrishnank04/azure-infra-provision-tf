# App Service (Linux Web App)
resource "azurerm_linux_web_app" "app_service" {
  for_each = var.webapp_name
  #for_each                      = toset(var.app_service_name)
  name                          = each.key
  location                      = var.location
  resource_group_name           = azurerm_resource_group.KnowledgeAssist_dev.name
  service_plan_id               = azurerm_service_plan.CKA-ASP-dev.id
  virtual_network_subnet_id     = azurerm_subnet.Pvt-Sub1.id
  https_only                    = true
  public_network_access_enabled = false
  site_config {
    container_registry_use_managed_identity = true
    vnet_route_all_enabled = true
    application_stack {
      docker_image_name   = "goodleapckafrontenddev:448" #application team need to update the already existing registry/image.
      docker_registry_url = "https://gchcreusddigitalgdlp01.azurecr.io" #application team need to update the already existing registry login server.
    }
  }

  app_settings = {
    "REDIS_CACHE_CONNECTION_STRING"         = azurerm_redis_cache.RedisCache-CKA-dev.primary_access_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.webapp_insights[each.value].connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.webapp_insights[each.value].instrumentation_key
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub1,
   azurerm_service_plan.CKA-ASP-dev, azurerm_application_insights.webapp_insights]
  
  lifecycle {
    ignore_changes = [tags, app_settings, sticky_settings, site_config ] # Ignoring the changes done by Application team from azure Portal
    #ignore_changes = [tags]
  }

}

# Private Endpoint for Linux Web App
resource "azurerm_private_endpoint" "app_service_endpoint" {
  #for_each            = toset(var.app_service_name)
  for_each            = var.webapp_name
  name                = "${each.key}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.KnowledgeAssist_dev.name
  subnet_id           = azurerm_subnet.Pvt-Sub5.id
  private_service_connection {
    name                           = "appServiceConnection"
    private_connection_resource_id = azurerm_linux_web_app.app_service[each.key].id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  tags = {
    ProvisionedVia = "Terraform"
  }
  depends_on = [azurerm_linux_web_app.app_service]

  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "wappdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.wapp_dns_zone.id]
  }

}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "wapp_dns_zone" {
  #provider            = azurerm.account_pvt_zones
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_linux_web_app.app_service ]
}
