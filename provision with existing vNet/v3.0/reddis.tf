data "azurerm_subnet" "db_subnet" {
  name                 = var.existing_db_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}

# Azure Redis Cache
resource "azurerm_redis_cache" "redis" {
  name                          = var.redis_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  capacity                      = 1
  family                        = "P"
  sku_name                      = "Premium"
  public_network_access_enabled = false
  lifecycle {
    ignore_changes = [tags]

  }
}

# Private Endpoint for Redis Cache
resource "azurerm_private_endpoint" "redis_endpoint" {
  name                = "${var.redis_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.db_subnet.id
  private_service_connection {
    name                           = "redisConnection"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }
  depends_on = [azurerm_redis_cache.redis]
  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "reddnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.red_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "red_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.pvt_dns_rg_name
}