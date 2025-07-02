resource "azurerm_service_plan" "CKA-ASP-dev" {
    name = var.ASP[1]
     location            = var.location
    resource_group_name = var.resource_group
    os_type             = var.ASP[1]
    sku_name            = var.ASP[2]
    depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
}