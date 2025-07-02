data "azurerm_subnet" "delegated_subnet_function_app" {
  name                 = var.existing_delegated_subnet_function_app_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}

data "azurerm_subnet" "private_subnet_03" {
  name                 = var.privatesubnet_03
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}

# Application Insights
resource "azurerm_application_insights" "funct_app_insights" {
  name                = "${var.function_app_name}-ain"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [azurerm_log_analytics_workspace.log_analytics]
}

# Azure Function App
resource "azurerm_linux_function_app" "function_app" {
  name                = var.function_app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.function_app_service_plan.id
  #storage_account_name          = azurerm_storage_account.function_storage.name
  storage_key_vault_secret_id   = azurerm_key_vault_secret.storage_account_connection_string.id
  virtual_network_subnet_id     = data.azurerm_subnet.delegated_subnet_function_app.id
  https_only                    = true
  public_network_access_enabled = false

  ftp_publish_basic_authentication_enabled = false

  site_config {
    application_stack {
      docker {
        registry_url = "https://mcr.microsoft.com"
        image_name   = "azure-functions/dotnet"
        image_tag    = "4-appservice-quickstart"
      }
    }
    always_on = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    #"AzureWebJobsStorage"     = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.keyvault.name}.vault.azure.net/secrets/AzureWebJobsStorage/${azurerm_key_vault_secret.storage_account_connection_string.version})",
    "WEBSITE_CONTENTOVERVNET" = "1"
    "vnetRouteAllEnabled"     = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" : "false"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.funct_app_insights.connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.funct_app_insights.instrumentation_key
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    # Application Specific Variables Constant for all Environemnts
    "ARCHIVAL_CONTAINER_NAME" : "archive"
    "BULK_UPLOAD_QUEUE" : "bulk-upload-queue"
    "INGESTION_QUEUE" : "ingestion-queue"
    "STORAGE_CONTAINER_NAME" : "docs"
    "OPENAI_API_VERSION" : "2024-02-15-preview"
    "OPENAI_DEPLOYMENT_NAME" : "text-embedding-ada-002"
    "SCHDULE" : "0 0 2 * * *"
    "DOCKER_ENABLE_CI" : "true"
    # Will Change based on Environment
    #"SERVICEBUS" : azurerm_key_vault_secret.sbus_account_connection_string.value
    "SERVICEBUS" = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.keyvault.name}.vault.azure.net/secrets/SERVICEBUSTFVAR/${azurerm_key_vault_secret.sbus_account_connection_string.version})"
    "KEY_VAULT_URL" : azurerm_key_vault.keyvault.vault_uri
  }

  lifecycle {
    #ignore_changes = [tags]
    ignore_changes = [tags,site_config] # Not tracking the ENV chnages 
  }

  depends_on = [azurerm_service_plan.function_app_service_plan, azurerm_storage_account.function_storage]

}

# Storage Account 2
resource "azurerm_storage_account" "function_storage" {
  name                          = var.function_storage_acc_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [tags]
  }
}

# Private Endpoint for Function App Storage Account 
resource "azurerm_private_endpoint" "blob_endpoint2" {
  name                = "${var.function_storage_acc_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  #subnet_id           = data.azurerm_subnet.private_subnet.id
  subnet_id = data.azurerm_subnet.private_subnet_03.id
  private_service_connection {
    name                           = "blobConnection"
    private_connection_resource_id = azurerm_storage_account.function_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [azurerm_storage_account.function_storage]

  private_dns_zone_group {
    name                 = "functblobdnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.function_storage_acc_name_dns_zone.id]
  }

}


# Fetch Private DNS zone for Function STorage account
data "azurerm_private_dns_zone" "function_storage_acc_name_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.pvt_dns_rg_name
}

# Private Endpoint for Linux Function App
resource "azurerm_private_endpoint" "function_app_endpoint" {
  name                = "${var.function_app_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet_03.id
  private_service_connection {
    name                           = "functionAppConnection"
    private_connection_resource_id = azurerm_linux_function_app.function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_linux_function_app.function_app]

  lifecycle {
    ignore_changes = [tags]
  }

  private_dns_zone_group {
    name                 = "lfndnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.lfn_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "lfn_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.pvt_dns_rg_name
}
