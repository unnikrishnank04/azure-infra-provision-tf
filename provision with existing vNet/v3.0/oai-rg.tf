
# Resource Group
resource "azurerm_resource_group" "oai_rg" {
  provider = azurerm.account_oai
  name     = var.oai_resource_group_name
  location = var.location
  tags = {
    ApplicationSupport = "Balraja.Dellimanickam@genpact.com"
    BusinessVertical   = "Consumer and healthcare(C&H)"
    CCCode             = 136
    Department         = "Finance & Accounting(F&A)"
    Owner              = "Siddhartha.Mahanta@genpact.com"
    OwnerSupervisor    = "brijesh.nayyar@genpact.com"
    PID                = 91680180
    ProjectName        = "Cora Knowledge Assist(Mars)"
    ProvisionedBy      = "xxxxxx@genpact.com"
    ProvisioningSR     = "RITMxxxxx-CHGxxxxx"
    SDOCode            = 8527
    ServiceType        = "IaaS"
    Stack              = "Prod"
    supportcost        = "$"
    ProvisionedVia     = "Terraform"
  }
}



