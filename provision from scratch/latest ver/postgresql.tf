#Postgresql server with Private endpoint
resource "azurerm_postgresql_flexible_server" "Postgresql-server-cka-dev" {
  name                = var.postgresql_name#"postgresql-server-cka-demo1"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  administrator_login = var.postgresql_admin #"dbadmin"
  administrator_password = var.postgresql_pass #"Genpact@123"
  sku_name            = var.postgresql_sku #"GP_Gen5_2"
  storage_mb          = 131072
  version             = "16"
  #ssl_enforcement_enabled = true
  backup_retention_days   = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled         = true
  public_network_access_enabled = false
  zone = "1"
  high_availability {
    mode                        = "ZoneRedundant"
    standby_availability_zone   = "2"  # Standby zone
  }
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub2 ]

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }
/*
  threat_detection_policy {
    enabled = true
    email_account_admins = true
  } */
}

resource "azurerm_private_endpoint" "Postgresql-cka-dev-Pvt-endpoint" {
  name                = "${var.postgresql_name}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub2.id
  depends_on = [ azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub2, azurerm_postgresql_flexible_server.Postgresql-server-cka-dev ]

  private_service_connection {
    name                           = "${var.postgresql_name}-privatesc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.Postgresql-server-cka-dev.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "postgresql_dnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgresql_zone.id]
  }
}

resource "azurerm_private_dns_zone" "postgresql_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql-Vnet-links" {
  name                  = "postgresql-Vnet-links"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_zone.name
  virtual_network_id    = azurerm_virtual_network.CKA-Vnet.id
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet ]
}
