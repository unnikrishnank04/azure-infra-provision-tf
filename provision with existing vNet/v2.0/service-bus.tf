# Service Bus Namespace
resource "azurerm_servicebus_namespace" "servicebus" {
  name                          = var.servicebus_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Premium"
  capacity                      = 1
  premium_messaging_partitions  = 1
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [tags]

  }
}

# Private Endpoint for Service Bus Namespace
resource "azurerm_private_endpoint" "servicebus_endpoint" {
  name                = "${var.servicebus_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet.id
  private_service_connection {
    name                           = "servicebusConnection"
    private_connection_resource_id = azurerm_servicebus_namespace.servicebus.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_servicebus_namespace.servicebus]

  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "sbusdnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sbus_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "sbus_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.pvt_dns_rg_name
}

# Get Connection string
resource "azurerm_servicebus_namespace_authorization_rule" "sbus_auth_rule" {
  name         = "${var.servicebus_name}-auth-rule"
  namespace_id = azurerm_servicebus_namespace.servicebus.id
  listen = true
  send   = true
  manage = false
}

# Store value as connection string as secret in KV
resource "azurerm_key_vault_secret" "sbus_account_connection_string" {
  name         = "SERVICEBUSTFVAR"
  value        = azurerm_servicebus_namespace_authorization_rule.sbus_auth_rule.primary_connection_string
  key_vault_id = azurerm_key_vault.keyvault.id
}