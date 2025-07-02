provider "azurerm" {
  features {
        key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
#  subscription_id = "1b5e485a-8825-4549-9eaa-d87817d92fc2"
#  tenant_id       = "958a7efb-f2a7-4ea2-80ee-85fc8ed01be7"
  use_msi         = true
}

# Account details where OpenAI has to be created
provider "azurerm" {
  alias = "account_oai"
  features {}
#  subscription_id = "b8dabb09-6d5a-4895-a713-090deeb4661e"
#  tenant_id       = "958a7efb-f2a7-4ea2-80ee-85fc8ed01be7"
  use_msi         = true
}

# Account details where Private DNS zones has to be created
provider "azurerm" {
  alias = "account_pvt_zones"
  features {}
#  subscription_id = "d6a7db39-1660-4df6-aadc-2d38a854b99c"
#  tenant_id       = "958a7efb-f2a7-4ea2-80ee-85fc8ed01be7"
  use_msi         = true
}