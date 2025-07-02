# variable "state_file_name" {
#   description = "Name of terraform state file for current deployment"
#   nullable = false
#   type = string
# }

# variable "deployment_account_name" {
#   description = "Provide ID of subscription whwre the resouce hsa to be deployed"
#   type = string
#   nullable = false
# }

# variable "openai_account_name" {
#   description = "Provide ID of subscription whwre the OAI resouces has to be deployed"
#   type = string
#   nullable = false
# }


# variable "identity_account_name" {
#   description = "Provide ID of subscription whwre the Private DNS zones are present"
#   type = string
#   nullable = false
# }

# variable "sr_cmr_details" {
#   description = "Provide SR and CMR number"
#   type = string
#   nullable = false
# }


variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources in"
  type        = string
}
#Windows VM Specific Veriables
variable "nic_name" {
  description = "Network interface name"
  type        = string
}

variable "win_vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for VM"
  type        = string
}

variable "disk_name" {
  description = "Managed disk name"
  type        = string
}

variable "datadisk_count" {
  description = "Number of Managed disk"
  type        = number
}

variable "nsg_name" {
  description = "Network security group name"
  type        = string
}

variable "existing_vnet_name" {
  description = "The name of the existing virtual network"
  type        = string
}
variable "existing_private_subnet_name" {
  description = "The name of the existing private subnet"
  type        = string
}


variable "existing_vm_private_subnet_name" {
  description = "The name of the existing private subnet Of VM"
  type        = string
}


variable "resource_group_name_vnet" {
  description = "The name of the resource group used for vnet"
  type        = string
}

variable "linux_nsg_name" {
  description = "Network security group name"
  type        = string
}

variable "linux_nic_name" {
  description = "Network interface name"
  type        = string
}

variable "linux_vm_name" {
  description = "Linux Virtual machine name"
  type        = string
}

variable "linux_admin_username" {
  description = "Admin username for VM"
  type        = string
}

variable "linux_admin_password" {
  description = "Admin password for VM"
  type        = string
}

variable "linux_disk_name" {
  description = "Managed disk name"
  type        = string
}

variable "linux_datadisk_count" {
  description = "Number of Managed disk"
  type        = number
}


# Storage account configuration starts

variable "blob_storage_name" {
  description = "The name of the blob storage account"
  type        = string
}

# Storage account configuration ends

# KeyVault configuration start

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID for the Key Vault"
  type        = string
}

# KeyVault configuration ends

# Redis configuration start

variable "redis_name" {
  description = "The name of the Redis cache"
  type        = string
}

variable "existing_db_subnet_name" {
  description = "The name of the existing database subnet"
  type        = string
}


# Redis configuration ends

# ACR configuration start

variable "container_registry_name" {
  description = "The name of the Container Registry"
  type        = string
}

# ACR configuration ends

# Azure AI service Content safety starts

variable "cognitive_account_name" {
  description = "The name of the Content Safety Cognitive Service account"
  type        = string
}

# Azure AI service Content safety ends

# Azure Document Intelligence Cognitive Service account starts
variable "document_intelligence_name" {
  description = "The name of the Document Intelligence Cognitive Service account"
  type        = string
}

# Azure Document Intelligence Cognitive Service account ends

# Azure Language Cognitive Service account starts
variable "language_account_name" {
  description = "The name of the Language Cognitive Service account"
  type        = string
}

# Azure Language Cognitive Service account ends

# Azure Service Bus namespace start

variable "servicebus_name" {
  description = "The name of the Service Bus namespace"
  type        = string
}

# Azure Service Bus namespace start

# WebApp Linux starts
variable "app_service_name" {
  description = "The name of the App Service"
  type        = map(string)
}

variable "webapp_insights_name" {
  description = "The name of the Application Insights resource"
  type        = list(string)
}

variable "service_plan_name" {
  description = "The name of the App Service plan"
  type        = string
}

variable "existing_delegated_subnet_name" {
  description = "The name of the existing private subnet"
  type        = string
}

# WebApp Linux endss

# FunctionApp Linux starts

variable "function_app_service_plan_name" {
  description = "The name of the function Service plan"
  type        = string
}


variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
}

variable "function_storage_acc_name" {
  description = "The name of the Function App"
  type        = string
}

variable "existing_delegated_subnet_function_app_name" {
  description = "The name of the existing private subnet"
  type        = string
}

# Making use of another private subnet to create the resource since the exisitng pool is exhaused
variable "privatesubnet_03" {
  description = "Mention the private subnet for function app to create private endpoints"
  type        = string
}
# FunctionApp Linux ends

# Variable for AI Search service starts here

variable "search_service_name" {
  description = "The name of the Cognitive Search service"
  type        = string
}

# Variable for AI Search service ends

# Variable for Application Insights and LAW start
variable "app_insights_name" {
  description = "The name of the Application Insights resource"
  type        = list(string)
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  type        = string
}

# Variable for Application Insights and LAW ends

# psql variables start

variable "postgresql_name" {
  description = "The name of the PostgreSQL server"
  type        = string
}

variable "postgresql_admin_login" {
  description = "The admin login for PostgreSQL server"
  type        = string
}

variable "postgresql_admin_password" {
  description = "The admin password for PostgreSQL server"
  type        = string
}

variable "postgresql_version" {
  description = "The PostgreSQL server version"
  type        = string
}

variable "postgresql_sku_name" {
  description = "The SKU name for PostgreSQL server"
  type        = string
}

variable "postgresql_storage_size_gb" {
  description = "The storage size for PostgreSQL server in GB"
  type        = number
}

variable "postgresql_backup_retention_days" {
  description = "The number of days to retain backups for PostgreSQL server"
  type        = number
}

variable "postgresqldb_name" {
  description = "The name of the PostgreSQL database"
  type        = string
}

variable "existing_postgresql_subnet_name" {
  description = "The name of the existing subnet for PostgreSQL Server"
  type        = string
}

# psql Varibales ends

#OpenAI Related Varibles

variable "oai_resource_group_name" {
  description = "Provide the RG of OpenAI resource in another account"
  type        = string
}

variable "oai_resource_name_south_central_us" {
  description = "Name of First OpenAI respurce  in Soth Central US"
  type        = string
}

# oai_resource_name_south_central_us

variable "oai_resource_name_north_central_us" {
  description = "Name of First OpenAI respurce  in Soth Central US"
  type        = string
}

#oai_resource_name_canada_east
variable "oai_resource_name_canada_east" {
  description = "Name of First OpenAI respurce  in Canada East"
  type        = string
}

variable "oai_resource_name_sweden_central" {
  description = "Name of First OpenAI respurce  in Sweden Central"
  type        = string
}

#oai_resource_name_australia_east
variable "oai_resource_name_australia_east" {
  description = "Name of First OpenAI respurce  in Australia East"
  type        = string
}

#oai_resource_name_eastus
variable "oai_resource_name_east_us" {
  description = "Name of First OpenAI respurce  in East Us"
  type        = string
}


variable "pvt_dns_rg_name" {
  description = "Provide Name of Resource Group where DNS zone is present and Record has to be added"
  type        = string
}

# AGW Varibales

variable "agw_key_vault" {
  description = "KeyVault created for storing SSL Certificate and Password"
  nullable = false
  type = string
}
variable "agw_pip_name" {
  description = "The name of the public IP address for the Application Gateway"
  type        = string
}

variable "agw_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "awg_waf_policy_name" {
  description = "Provide Name of WAF Policy"
  nullable    = false
  type        = string

}

variable "existing_public_subnet_name" {
  description = "The name of the existing public subnet"
  type        = string
}

variable "selected_web_apps_front_end" {
  description = "A list of Web App names to include in the Front end address pool."
  type        = list(string)
}

variable "selected_web_apps_backed_end" {
  description = "A list of Web App names to include in the backend address pool."
  type        = list(string)
}

# APIM variables
variable "apim_name" {
  description = "The name of the API Management service"
  type        = string
}

variable "apim_publisher_name" {
  description = "The name of the API Management publisher"
  type        = string
}

variable "apim_publisher_email" {
  description = "The email of the API Management publisher"
  type        = string
}

variable "apim_subnet" {
  description = "The name of the existing private subnet"
  type        = string
}

variable "apim_sku_detail" {
  description = "Provide APIM SKU details"
  type = string
  nullable = false
}