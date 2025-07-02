data "azurerm_subnet" "postgresql_subnet" {
  name                 = var.existing_postgresql_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}

# Retrieve information about an existing Virtual Network
data "azurerm_virtual_network" "identity_vnet" {
  provider            = azurerm.account_pvt_zones
  name                = "gch-eus-prod-shared-identity"
  resource_group_name = "gch-rg-eus-prod-shared-identity-core-network"
}

# Azure PostgreSQL Flexible Server Database
resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                          = var.postgresql_name
  location                      = "eastus"
  resource_group_name           = azurerm_resource_group.rg.name
  administrator_login           = var.postgresql_admin_login
  administrator_password        = var.postgresql_admin_password
  version                       = var.postgresql_version
  sku_name                      = var.postgresql_sku_name
  storage_mb                    = var.postgresql_storage_size_gb * 1024
  backup_retention_days         = var.postgresql_backup_retention_days
  zone                          = "1"
  public_network_access_enabled = false
  delegated_subnet_id           = data.azurerm_subnet.postgresql_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql_dns_zone.id
  geo_redundant_backup_enabled  = true

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  lifecycle {
    ignore_changes = [tags]

  }
}

# Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_database" "postgresqldb" {
  name       = var.postgresqldb_name
  server_id  = azurerm_postgresql_flexible_server.postgresql.id
  collation  = "en_US.utf8"
  charset    = "utf8"
  depends_on = [azurerm_postgresql_flexible_server.postgresql]
}

# For DNS Integration of PostgreSQL Server
resource "azurerm_private_dns_zone" "postgresql_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "${var.postgresql_name}.private.postgres.database.azure.com"
  resource_group_name = var.pvt_dns_rg_name
  lifecycle {
    ignore_changes = [tags]

  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "PostgreSQL_dns_zone_vnet_link" {
  provider              = azurerm.account_pvt_zones
  name                  = "postgresql_vnet_dns_zone_link_com"
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.identity_vnet.id
  resource_group_name   = var.pvt_dns_rg_name
  depends_on            = [data.azurerm_virtual_network.identity_vnet]

  lifecycle {
    ignore_changes = [tags]
  }

}
