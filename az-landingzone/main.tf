module "network" {
  source              = "./modules/network"
  prefix              = var.name_prefix
  location            = var.location
  hub_address_space   = var.hub_address_space
  spoke_address_spaces = var.spoke_address_spaces
  tags                = var.tags
}

module "monitoring" {
  source     = "./modules/monitoring"
  prefix     = var.name_prefix
  location   = var.location
  admin_email = var.admin_email
  tags       = var.tags
}

module "keyvault" {
  source   = "./modules/keyvault"
  prefix   = var.name_prefix
  location = var.location
  tags     = var.tags
}

module "policies" {
  source = "./modules/policies"
}
