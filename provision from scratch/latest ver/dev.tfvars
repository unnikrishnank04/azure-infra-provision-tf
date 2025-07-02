#Environment & Resource Group
environment = "Dev"
resource_group = "KnowledgeAssist_dev1"
location = "East US"
OS = [ "Linux", "Windows" ]

#Network Details
vnet_name = "CKA-Vnet"
address_space = "10.0.1.0/24"
subnet_name = ["Pub-Subnet-App-Gateway", "WebApp-Subnet", "Database-Subnet", "AISearch-Subnet", "VM-Subnet", "Int-Sub"]
subnet_range = ["10.0.1.0/27", "10.0.1.32/27", "10.0.1.64/27", "10.0.1.96/27", "10.0.1.128/27", "10.0.1.160/27" ]

#Application Gateway Details:
agw_key_vault = "/subscriptions/7f770ce7-a2df-43ef-b60f-bd1aa82812d9/resourceGroups/KnowledgeAssist_dev1/providers/Microsoft.KeyVault/vaults/keyvault-cka-dev"
frontend_public_IP_name = "Frontend-AppGateway-Public-IP1"
AppGateway_name = "AppGateway-CKA-dev"
frontend_pool_webapp_name = ["cka-frontend-dev"]
backend_pool_webapp_name = ["cka-backend-dev"]
AppGateway_WAF_Policy_name = "AppGateway_WAF-dev"
#Integrations
container_registry_name = "acrckadev"
container_registry_sku = ["Basic", "Standard", "Premium"]
KeyVault_name = "keyvault-cka-dev"
#servicebus_name = "Servicebus-cka-dev"
servicebus_sku_tier = "Basic"
#APIM_public_IP_name = "APIM-Public-IP1"
#API_Management = [ "API-Management-CKA-dev", "Developer_1" ]

#WebApp Services
ASP = ["cka-asp-dev", "Linux", "P2v3", "FunctionApp-ASP-CKA-dev"]
webapp_name = {
      "cka-frontend-dev" : "cka-frontend-dev-appinsights",
      "cka-backend-dev" : "cka-backend-dev-appinsights",
      "cka-celery-dev" : "cka-celery-dev-appinsights"
  }
webapp_insights_name = [ "cka-frontend-dev-appinsights", "cka-backend-dev-appinsights", "cka-celery-dev-appinsights"]
app_insights = ["cka-Backend-data", "cka-Ingestion-data"]
log_analytics_workspace = "cka-log-analytics-workspace"
storage_account = [ "ckadev", "Standard", "ZRS", "StorageV2"]

#Databases
postgresql_name = "postgresql-server-cka-dev"
postgresql_admin = "dbadmin"
postgresql_pass = "dbadmin@123"
postgresql_sku = "GP_Standard_D4ads_v5"
redis_cache_name = "RedisCache-cka-dev"
redis_cache_sku_name = "Premium"
rediscache_family_type = "P"

#Function App Services
FunctionApp_ServicePlan_name = "FunctionApp-ASP-CKA-dev"
fap_serviceplan_tier = [ "Premium", "P2V3" ]
fap_storage_name = "storageckadev0"
fap_storage_account = ["Standard", "ZRS"]
functionapp_name = "FunctionApp-CKA-dev"

#AI Search Services
AISearch_Service = ["searchserviceckadev1", "standard2", "Dev"]
Form_Recognizer = ["Form_Recognizer-CKA-dev", "S0", "formrecognizerckadev"]
AILanguage_Service = ["AILanguage_Service-CKA-dev", "S1"]
Content_Safety = ["Content-Safety-CKA-dev", "S0"]

#OpenAI Instances
OpenAI_Instance = [ "OpenAI-Instance1-CKA-DSI", "OpenAI-Instance2-CKA-DSI", "OpenAI-Instance3-CKA-DSI", "OpenAI-Instance4-CKA-DSI" ]


#VM details
vm_Windows_nic = "windows_VM_nic"
vm_Linux_nic = "Linux_VM_nic"
Win_vm = "Windows-2022"
Linux_vm = "ubuntu-24.04-LTS"
admin_usernamer = "genpactadmin"
admin_password = "genpact@123"
Win_disk_name = "Windows-2022_disk"
Linux_disk_name = "Ubuntu-24.04-LTS_disk"
datadisk_count = 1
Linux_data_disk_count = 1
Win_nsg_name = "Win_nsg"
Linux_nsg_name = "Linux_nsg"
