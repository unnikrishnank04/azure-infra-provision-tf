location              = "eastus"
name_prefix           = "unni-demo-lz"
admin_email           = "admin@example.com"

hub_address_space     = "10.0.0.0/24"
spoke_address_spaces  = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

tags = {
  Environment = "Demo"
}
