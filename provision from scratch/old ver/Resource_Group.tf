resource "azurerm_resource_group" "KnowledgeAssist_dev" {
  name     = var.resource_group
  location = var.location
  tags = {
    ApplicationSupport = "aimlpractice@genpact.com"
    BusinessVertical = "AIML Practice"
    ProvisioningSR = "NIL"
    ProjectName = "CKA-CoraKnowledgeAssist"
    SDOCode = "8535"
    Stack = "React, Python"
    PID = "91536489"
    CCCode = "132"
    Owner = "703319176, 703382316"
    OwnerSupervisor = "omprakash.ranakoti@genpact.com"
    supportcost = "NIL"
    ProvisionedBy = "703382316"
    Department = "DSI"
    Environment = var.environment
  }
}