data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "kv" {
  name     = "${var.prefix}-kv-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "vault" {
  name                        = "${var.prefix}-kv"
  location                    = azurerm_resource_group.kv.location
  resource_group_name         = azurerm_resource_group.kv.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  # Access policy granting current identity full secret permissions
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["get", "list", "set", "delete"]
  }

  tags = var.tags
}
