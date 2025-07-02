The terraform.tfvars file contains custom values for input variables defined in your variables.tf. This will be reusable across the environments

 Variable                Purpose                                                              
 `location`              Azure region for deployment (`East US` in your case)                 
 `name_prefix`           Prefix used to name all resources (e.g., `unni-demo-lz-hub-vnet`)    
 `admin_email`           Email to receive Azure Monitor alerts                                
 `hub_address_space`     CIDR block for the hub VNet                                          
 `spoke_address_spaces`  List of CIDR blocks for spoke VNets (you can add more)               
 `tags`                  Tags applied to all resources (helps with cost mgmt, tracking, etc.) 


While runing the code

terraform apply -var-file="terraform.tfvars"


Terraform will load these values and pass them into  modules.