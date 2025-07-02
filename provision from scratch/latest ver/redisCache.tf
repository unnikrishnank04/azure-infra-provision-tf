#RedisCache with private endpoint

resource "azurerm_redis_cache" "RedisCache-CKA-dev" {
  name                = var.redis_cache_name #"RedisCache-cka-demo1"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  capacity            = 1
  family              = var.rediscache_family_type # "C"
  sku_name            = var.redis_cache_sku_name #"Standard"

  #non_ssl_port_enabled = false
  minimum_tls_version = "1.2"
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub2 ]
}

resource "azurerm_private_endpoint" "RedisCache-CKA-dev-Pvt-endpoint" {
  name                = "${var.redis_cache_name}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub2.id
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub2, azurerm_redis_cache.RedisCache-CKA-dev ]

  private_service_connection {
    name                           = "rediscache-privatesc"
    private_connection_resource_id = azurerm_redis_cache.RedisCache-CKA-dev.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "redisdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_dns_zone.id]
  }
}


# Create a Private DNS zone
resource "azurerm_private_dns_zone" "redis_dns_zone" {
  #provider            = azurerm.account_pvt_zones
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group #If possible pls create a different resource group for DNS zones.
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}
