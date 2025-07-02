#Creating Virtual Network:
resource "azurerm_virtual_network" "CKA-Vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group 
  address_space       = [var.address_space]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev ]
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

resource "azurerm_subnet" "Pub-Sub1-App-Gateway" {   #AppGateway1
  name                 = var.subnet_name[0]
  resource_group_name  = var.resource_group  #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name  #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[0]] #10.0.1.0/27 #32
  depends_on = [ azurerm_virtual_network.CKA-Vnet ]
  
}

resource "azurerm_subnet" "Pvt-Sub1" {  #Web App Services
  name                 = var.subnet_name[1]
  resource_group_name  = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[1]]  #64 -->95
  depends_on = [ azurerm_virtual_network.CKA-Vnet]
  
  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "Pvt-Sub2" {   #Redis Cache, Postgresql
  name                 = var.subnet_name[2]
  resource_group_name  = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[2]] #["10.0.0.96/26"]   #64 --> 160
  depends_on = [ azurerm_subnet.Pvt-Sub1 ]
}

resource "azurerm_subnet" "Pvt-Sub3" {  #AI Search Service, OpenAI Instance
  name                 = var.subnet_name[3] #"Pvt-Sub3"
  resource_group_name  = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[3]] #["10.0.0.160/26"] #32 --> 224
  depends_on = [ azurerm_subnet.Pvt-Sub2 ]
}

resource "azurerm_subnet" "Pvt-Sub4" {  #VM - Linux, Windows
  name                 = var.subnet_name[4] #"Pvt-Sub4"
  resource_group_name  = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[4]] # ["10.0.0.224/27"]  #32 --> 256
  depends_on = [  azurerm_subnet.Pvt-Sub3 ]
}

resource "azurerm_subnet" "Pvt-Sub5" {  #Int-Sub5 - ACR, KeyVault, storage
  name                 = var.subnet_name[5] #"Pvt-Sub4"
  resource_group_name  = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_demo1.name
  virtual_network_name = var.vnet_name #azurerm_virtual_network.CKA-demo1.name
  address_prefixes     = [var.subnet_range[5]] # ["10.0.0.224/27"]  #32 --> 256
  service_endpoints = [
    "Microsoft.KeyVault"
  ]
  depends_on = [  azurerm_subnet.Pvt-Sub4 ]
}