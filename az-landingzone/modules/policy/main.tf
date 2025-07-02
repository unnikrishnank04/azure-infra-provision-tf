data "azurerm_client_config" "current" {}

# Enforce tags on all resources
resource "azurerm_policy_assignment" "require_tag_resources" {
  name                 = "require-tag-resources"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"  // "Require a tag on resources"
  display_name         = "Require Tag on all Resources"
  description          = "Ensures that all resources have at least one tag"
}

# Enforce tags on all resource groups
resource "azurerm_policy_assignment" "require_tag_rgs" {
  name                 = "require-tag-rgs"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"  // "Require a tag on resource groups"
  display_name         = "Require Tag on Resource Groups"
  description          = "Ensures that all resource groups have at least one tag"
}

# Restrict allowed locations for resources ( East US only)
resource "azurerm_policy_assignment" "allowed_locations_resources" {
  name                 = "allowed-locations-resources"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"  // "Allowed locations"
  display_name         = "Allowed Locations for Resources"
  description          = "Restricts resource creation to specified locations"
  parameters = <<PARAMETERS
  {
    "listOfAllowedLocations": {
      "value": ["eastus"]
    }
  }
  PARAMETERS
}

# Restrict allowed locations for resource groups (East US only)
resource "azurerm_policy_assignment" "allowed_locations_rgs" {
  name                 = "allowed-locations-rgs"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"  // "Allowed locations for resource groups"
  display_name         = "Allowed Locations for Resource Groups"
  description          = "Restricts resource group creation to specified locations"
  parameters = <<PARAMETERS
  {
    "listOfAllowedLocations": {
      "value": ["eastus"]
    }
  }
  PARAMETERS
}
