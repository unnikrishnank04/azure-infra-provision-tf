variable "environment" {
    description = "The environment to deploy: dev, uat, prod"
    type = string
 #   default = "dev"
}

variable "resource_group" {
    description = "writing the resource group name"
    type = string
 #   default = "KnowledgeAssist_V2_dev"
}

variable "location" {
    description = "Updating the location name"
    type = string
 #   default = "EastUS"
}

#Passing Network Variables
variable "vnet_name" {
    description = "virtual network name"
    type = string
 #   default = "cka-vnet-dev"
}

variable "address_space" {
    description = "update the address_space value"
    type = string
 #   default = "10.0.0.0/24"
}

#Updating the Subnet variables.
variable "subnet_name" {
    description = "updating the subnet names"
#    type = list(string)
 #   default = ["Pub-Sub1-App-Gateway", "Pub-Sub2-App-Gateway", "Pvt-Sub1", 
 #   "Pvt-Sub2", "Pvt-Sub3", "Pvt-Sub4", "Pvt-Sub5", "Pvt-Sub6", "Int-Sub1", 
 #   "Int-Sub2"]
}

variable "subnet_range" {
    description = "updating the subnet ranges"
    type = list(string)
 #   default = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/27", "10.0.0.64/27", "10.0.0.96/27", 
 #   "10.0.0.128/27", "10.0.0.160/27", "10.0.0.192/27", "10.0.0.224/28", "10.0.0.240/28"]
}

variable "frontend_public_IP_name" {
    description = "update the frontend IP Address to the AppGateway"
    type = string
 #   default = "Frontend-AppGateway-Public-IP1"
}

#Application Gateway 
variable "agw_key_vault" {
  description = "KeyVault created for storing SSL Certificate and Password"
  nullable = false
  type = string
}
variable "AppGateway_name" {
    description = "updating the application gateway name"
    type = string
 #   default = "AppGateway-CKA-dev"
}

variable "frontend_pool_webapp_name" {
    description = "Updating the backend"
    type = list(string)
    #default = [ " " ]
}

variable "backend_pool_webapp_name" {
    description = "Updating the backendapi"
    type = list(string)
    #default = [ " " ]
}

variable "AppGateway_WAF_Policy_name" {
    description = "updating the AppGateway WAF Policy"
    type = string
   # default = ""
  
}

#Container Registry
variable "container_registry_name" {
    description = "updating the container registry name"
    type = string
 #   default = "acrdev25"
}

variable "KeyVault_name" {
    description = "updating the container KeyVault name"
    type = string
 #   default = "keyvaultckadev"
}

variable "container_registry_sku" {
    description = "updating the container registry sku"
    type = list(string)
 #   default = ["Basic", "Standard", "Premium"]
}

#WebApp Services
variable "ASP" {
    description = "Updating the Webapplication app service plan"
    type = list(string)
 #   default = ["cka-asp-dev", "Premium", "P2V3", "FunctionApp-ASP-CKA-dev"]
}

variable "OS" {
    description = "Updating the OS name"
    type = list(string)
 #   default = [ "Linux", "Windows" ]
}


variable "webapp_name" {
    description = "updating the webapplication service"
    type = map(string)
 #   default = [ "cka-frontend-dev", "cka-backend-dev", "cka-celery-dev" ]
}

variable "webapp_insights_name" {
    description = "Updating the webapp related insights"
    type = list(string)
   #default = ["cka-frontend-dev-appinsights", "cka-backend-dev-appinsights", "cka-celery-dev-appinsights"]
  
}
variable "app_insights" {
    description = "Updating the application insights details"
    type = list(string)
    #default = ["gch-ain-eus-prod-digital-mars-04-Backend-data", "gch-ain-eus-prod-digital-mars-05-Ingestion-data"]
}

#Log Analytic Work Space
variable "log_analytics_workspace" {
    description = "Updating the log analytics workspace"
    type = string
}


#Storage account
variable "storage_account" {
    description = "updating the storage account name"
    type = list(string)
 #   default = [ "ckadev", "Standard", "LRS"]
}

#Postgresql database
variable "postgresql_name" {
    description = "Updating the postgresql name"
    type = string
 #   default = "postgresql-server-cka-dev"
}

variable "postgresql_admin" {
    description = "updating the postgresql user name"
    type = string
 #   default = "dbadmin"
}

variable "postgresql_pass" {
    description = "updating the password of Postgersql admin user."
    type = string
 #   default = "dbadmin@123"
}

variable "postgresql_sku" {
    description = "Updating the postgresql sku details."
    type = string
 #   default = "GP_Standard_D4ads_v5"
}

variable "redis_cache_name" {
    description = "update the redis cache name"
    type = string
 #   default = "RedisCache-cka-dev"
}

variable "redis_cache_sku_name" {
    description = "updating the rediscache sku tier"
    type = string
    default = "Basic"
}

variable "rediscache_family_type" {
    description = "update the family type of redis cache"
    type = string
    default = "C"
}

variable "servicebus_name" {
    description = "updating the ServiceBus name"
    type = string
    default = "Servicebus-cka-dev"
}

variable "servicebus_sku_tier" {
    description = "updating the service bus sku tier details."
    type = string
    default = "Basic"
}


#Function App:
/*
variable "FunctionApp_ServicePlan_name" {
    description = "updating the function app service plan"
    type = string
    default = "FunctionApp-ASP-CKA-dev"
}*/

variable "fap_serviceplan_tier" {
    description = "Updating the functionapp app service plan tier"
    type = list(string)
    default = [ "Premium", "P2V3" ]
}

variable "fap_storage_name" {
    description = "update the functionapp's storage account name"
    type = string
    default = "storageckadev0"
}

variable "fap_storage_account" {
    description = "updating the function app storage account configuration details"
    type = list(string)
    default = ["Standard", "ZRS"]
}

variable "functionapp_name" {
    description = "Updating the functionapp name"
    type = string
    default = "FunctionApp-CKA-dev"
}

variable "AISearch_Service" {
    description = "Updating the AI Search service name"
    type = list(string)
    default = ["searchserviceckadev", "basic", "Dev"]  
}

variable "Form_Recognizer" {
    description = "Update the form-recognizer details"
    type = list(string)
    default = ["Form_Recognizer-CKA-dev", "S0", "formrecognizerckadem1"]
}

variable "AILanguage_Service" {
    description = "Updating the AI Language service"
    type = list(string)
    default = ["AILanguage_Service-CKA-dev", "S1"]
}

variable "Content_Safety" {
    description = "updating the content safety details."
    type = list(string)
    default = ["Content-Safety-CKA-dev", "S0"]
  
}

variable "APIM_public_IP_name" {
    description = "update the frontend IP Address to the AppGateway"
    type = string
    default = "APIM-Public-IP1"
}

variable "API_Management" {
    description = "updating the API_management details"
    type = list(string)
    default = [ "API-Management-CKA-dev", "Developer_1" ]
  
}

variable "OpenAI_Instance" {
    description = "Updating the OpenAI instances details"
    type = list(string)
 #   default = [ "OpenAI-Instance1-CKA-DSI", "OpenAI-Instance2-CKA-DSI", "OpenAI-Instance3-CKA-DSI", "OpenAI-Instance4-CKA-DSI" ]
  
}

variable "vm_Windows_nic" {
    description = "updating the vm nic details"
    type = string
}

variable "vm_Linux_nic" {
    description = "updating the vm nic details"
    type = string
}

variable "Win_vm" {
    description = "updating the windows vm  details"
    type = string
}

variable "Linux_vm" {
    description = "updating the Linux vm  details"
    type = string
}

variable "admin_usernamer" {
    description = "updating the Linux vm  details"
    type = string
}
variable "admin_password" {
    description = "updating the Linux vm  details"
    type = string
}

variable "Win_disk_name" {
    description = "updating the Linux vm  details"
    type = string
}

variable "Linux_disk_name" {
    description = "updating the Linux vm  details"
    type = string
}

variable "datadisk_count" {
    description = "updating the Linux vm  details"
    type = number
}

variable "Linux_data_disk_count" {
    description = "updating the Linux vm  details"
    type = string
}
variable "Win_nsg_name" {
    description = "updating the Linux vm  details"
    type = string
}
variable "Linux_nsg_name" {
    description = "updating the Linux vm  details"
    type = string
}