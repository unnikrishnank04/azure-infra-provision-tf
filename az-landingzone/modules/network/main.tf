# Resource group for all network resources
resource "azurerm_resource_group" "network_rg" {
  name     = "${var.prefix}-network-rg"
  location = var.location
  tags     = var.tags
}

# Hub Virtual Network (for shared services)
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = [var.hub_address_space]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  tags                = var.tags
}

# Gateway subnet in the hub (reserved for VPN/ExpressRoute)
resource "azurerm_subnet" "hub_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.0.0/27"]
}

# Create one or more Spoke VNets using the provided address ranges
resource "azurerm_virtual_network" "spoke_vnet" {
  for_each            = toset(var.spoke_address_spaces)
  name                = "${var.prefix}-spoke-vnet-${replace(each.value, ".", "-")}"
  address_space       = [each.value]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  tags                = var.tags
}

# Subnet in each spoke (using the entire spoke range as one subnet for demo)
resource "azurerm_subnet" "spoke_subnet" {
  for_each = toset(var.spoke_address_spaces)
  name                 = "default"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet[each.value].name
  address_prefixes     = [each.value]
}

# Peering: Hub-to-Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                = toset(var.spoke_address_spaces)
  name                    = "${var.prefix}-hub-to-spoke-peering-${replace(each.value, ".", "-")}"
  resource_group_name     = azurerm_resource_group.network_rg.name
  virtual_network_name    = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet[each.value].id
  allow_virtual_network_access = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = true
  use_remote_gateways           = false
}

## Peering: Spoke-to-Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                = toset(var.spoke_address_spaces)
  name                    = "${var.prefix}-spoke-to-hub-peering-${replace(each.value, ".", "-")}"
  resource_group_name     = azurerm_resource_group.network_rg.name
  virtual_network_name    = azurerm_virtual_network.spoke_vnet[each.value].name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}
