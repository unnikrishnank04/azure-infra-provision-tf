#KeyVault with private endpoint
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "cka-keyvault-dev" {
  name                        = var.KeyVault_name #"keyvaultckadev"
  location                    = var.location#azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name         = var.resource_group#azurerm_resource_group.KnowledgeAssist_V2_dev.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub1, azurerm_container_registry.ACR-dev ]
  # Soft delete and purge protection (optional but recommended)
  soft_delete_retention_days = 90
  purge_protection_enabled     = true

  /*
  # Access policy example (Optional, add policies here if needed)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    # Permissions to secrets, keys, and certificates
    secret_permissions = [ "Get", "List", "Set", "Delete" ]
    key_permissions = [ "Get", "Create", "Delete", "Create", "List" ]
  }
  */

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules = []
    virtual_network_subnet_ids = [azurerm_subnet.Pvt-Sub5.id]
  }
}


# Data source to fetch the details of the Azure Linux Web App
data "azurerm_linux_web_app" "app_service_details" {
  #for_each = toset(var.app_service_name)
  for_each            = var.webapp_name
  name                = each.key
  resource_group_name = var.resource_group
  depends_on          = [azurerm_linux_web_app.app_service]
}

resource "azurerm_key_vault_access_policy" "webapp_Insights" {
  for_each         = data.azurerm_linux_web_app.app_service_details
  key_vault_id = azurerm_key_vault.cka-keyvault-dev.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id # Getting Object ID of web App
  #key_permissions = ["Get","List"]
  secret_permissions = ["Get", "List"]
}

/*
resource "azurerm_key_vault_access_policy" "web_app_access" {
  for_each           = data.azurerm_linux_web_app.app_service
  key_vault_id       = azurerm_key_vault.cka-keyvault-dev.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = each.value.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}


# Granting acees to Windows VM
resource "azurerm_key_vault_access_policy" "win_vm_kv_access" {
  key_vault_id       = azurerm_key_vault.cka-keyvault-dev.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_windows_virtual_machine.Win_vm.identity[0].principal_id
  secret_permissions = ["Get", "List", "Set", "Delete"]
}*/

/*
# Granting acees to Linux VM
resource "azurerm_key_vault_access_policy" "linux_vm_kv_access"{
  key_vault_id       = azurerm_key_vault.cka-keyvault-dev.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_virtual_machine.Linux_VM.identity[0].principal_id
  secret_permissions = ["Get", "List", "Set", "Delete"]
}


resource "azurerm_key_vault_access_policy" "tf_access" {
  key_vault_id = azurerm_key_vault.cka-keyvault-dev.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "6bc1838c-1b0f-48d5-9751-861b6ab958ba" # Terraform server Object ID
  #key_permissions = ["Get","List"]
  secret_permissions = ["Get", "List", "Set", "Delete"]
}


resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  name         = "AzureWebJobsStorage"
  value        = azurerm_storage_account.function_storage.primary_connection_string
  key_vault_id = azurerm_key_vault.keyvault.id
}

*/

resource "azurerm_private_endpoint" "keyvault-cka-dev-pvt-endpoint" {
  name                = "${var.KeyVault_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.Pvt-Sub5.id

  private_service_connection {
    name                           = "${var.KeyVault_name}-private-connection"
    private_connection_resource_id = azurerm_key_vault.cka-keyvault-dev.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "akvdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.akv_dns_zone.id]
  }
}


# Create a Private DNS zone
resource "azurerm_private_dns_zone" "akv_dns_zone" {
 # provider            = #azurerm.account_pvt_zones
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}
