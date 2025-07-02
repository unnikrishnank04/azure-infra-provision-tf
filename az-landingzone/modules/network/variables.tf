variable "prefix" {
  description = "Name prefix (e.g. 'unni-demo-lz')"
}
variable "location" {
  description = "Azure region"
}
variable "hub_address_space" {
  description = "CIDR for Hub VNet"
}
variable "spoke_address_spaces" {
  description = "List of CIDRs for spoke VNets"
  type        = list(string)
}
variable "tags" {
  description = "Tags to apply to networking resources"
  type        = map(string)
}

output "hub_vnet_id" {
  description = "ID of the Hub VNet"
  value       = azurerm_virtual_network.hub_vnet.id
}
output "spoke_vnet_ids" {
  description = "IDs of the Spoke VNets"
  value       = [for v in azurerm_virtual_network.spoke_vnet : v.id]
}
