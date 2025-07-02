variable "location" {
  description = "Azure region"
  default     = "eastus"
}
variable "name_prefix" {
  description = "Prefix for resource names"
  default     = "unni-demo-lz"
}
variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {
    Environment = "Demo"
  }
}
variable "admin_email" {
  description = "Notification email for alerts"
  default     = "unnikrishnank.in@gmail.com"
}
variable "hub_address_space" {
  description = "CIDR for the hub VNet"
  default     = "10.0.0.0/24"
}
variable "spoke_address_spaces" {
  description = "CIDRs for spoke VNets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
