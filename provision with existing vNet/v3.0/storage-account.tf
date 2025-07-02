# Blob Storage Account
resource "azurerm_storage_account" "blob_storage" {
  name                          = var.blob_storage_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  #enable_https_traffic_only     = true # Disabling deplicated parameter
  #https_traffic_only_enabled = true
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  sftp_enabled              = false
  shared_access_key_enabled = true
  is_hns_enabled            = true # REQUIRED: Should be "false" disabled to do bulk upload files
  lifecycle {
    ignore_changes = [tags]

  }

}


# Blob Private Endpoint
resource "azurerm_private_endpoint" "blob_endpoint" {
  name                = "${var.blob_storage_name}-pvt-ep"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.private_subnet.id
  private_service_connection {
    name                           = "blobConnection"
    private_connection_resource_id = azurerm_storage_account.blob_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  depends_on = [azurerm_storage_account.blob_storage]
  lifecycle {
    ignore_changes = [tags]

  }

  private_dns_zone_group {
    name                 = "blobdnszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.blob_dns_zone.id]
  }

}

# Create a Private DNS zone
data "azurerm_private_dns_zone" "blob_dns_zone" {
  provider            = azurerm.account_pvt_zones
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.pvt_dns_rg_name
}