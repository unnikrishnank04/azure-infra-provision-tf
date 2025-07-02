resource "azurerm_storage_account" "CKA-Storage-dev" {
  name                     = var.storage_account[0] #"ckademo1"
  resource_group_name      = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  location                 = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  account_tier             = var.storage_account[1] #"Standard"
  account_replication_type = var.storage_account[2]  #"LRS"
  account_kind             = var.storage_account[3] #"StorageV2" 
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub5 ]

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

resource "azurerm_private_endpoint" "Storage-Pvt-endpoint" {
  name                = "${var.storage_account[0]}-Pvt-endpoint"
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_demo1.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  subnet_id           = azurerm_subnet.Pvt-Sub5.id
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub5, azurerm_storage_account.CKA-Storage-dev ]

  private_service_connection {
    name                           = "${var.storage_account[0]}-privatesc"
    private_connection_resource_id = azurerm_storage_account.CKA-Storage-dev.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blobdnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_dns_zone.id]
  }

}

# Create a Private DNS zone
resource "azurerm_private_dns_zone" "blob_dns_zone" {
 # provider            = azurerm.account_pvt_zones
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]

}