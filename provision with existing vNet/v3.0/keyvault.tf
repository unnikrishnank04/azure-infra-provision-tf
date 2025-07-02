data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  # network_acls {
  #   bypass         = "None"
  #   default_action = "Deny"
  # }

  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = ["165.225.0.0/17", "136.226.0.0/16"]
    # Keep this to manage the KV from TF server
    virtual_network_subnet_ids = ["/subscriptions/de52f15e-9c68-4673-b173-9de91aa89657/resourceGroups/gch-eus-shared-prod-rg/providers/Microsoft.Network/virtualNetworks/gch-eus-shared-prod-vnet/subnets/gch-eus-shared-prod-private"] # Terraform Server Network allowed to managed it
  }

  lifecycle {
    ignore_changes = [tags]

  }
}


# Data source to fetch the details of the Azure Linux Web App
data "azurerm_linux_web_app" "app_service_details" {
  #for_each = toset(var.app_service_name)
  for_each            = var.app_service_name
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_linux_web_app.app_service]
}

resource "azurerm_key_vault_access_policy" "web_app_access" {
  for_each           = data.azurerm_linux_web_app.app_service_details
  key_vault_id       = azurerm_key_vault.keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = each.value.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

# Granting acees to Windows VM
resource "azurerm_key_vault_access_policy" "win_vm_kv_access" {
  key_vault_id       = azurerm_key_vault.keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_windows_virtual_machine.vm.identity[0].principal_id
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

# Granting acees to Linux VM
resource "azurerm_key_vault_access_policy" "linux_vm_kv_access"{
  key_vault_id       = azurerm_key_vault.keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_virtual_machine.linux_vm.identity[0].principal_id
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_access_policy" "tf_access" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "cba497a2-358b-47f2-b23b-083b74de4fc3" # Terraform server Object ID
  #key_permissions = ["Get","List"]
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  name         = "AzureWebJobsStorage"
  value        = azurerm_storage_account.function_storage.primary_connection_string
  key_vault_id = azurerm_key_vault.keyvault.id
}

# Private Endpoint for key vault
resource "azurerm_private_endpoint" "keyvault_endpoint" {
  name                = "${var.key_vault_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet.id
  private_service_connection {
    name                           = "keyvaultConnection"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  depends_on = [azurerm_key_vault.keyvault]

  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "akvdnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.akv_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "akv_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.pvt_dns_rg_name
}
