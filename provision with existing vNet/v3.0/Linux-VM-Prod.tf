resource "azurerm_network_interface" "linux_nic" {
  name                = var.linux_nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  # ip_configuration {
  #   name                          = "internal"
  #   subnet_id                     = data.azurerm_subnet.private_subnet.id
  #   private_ip_address_allocation = "Dynamic"
  # }
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vm_private_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.249.147.52"
  }
  lifecycle {
    ignore_changes = [tags]

  }
}

# Mapping the NIC created via azure portal
# data "azurerm_network_interface" "linux_vm_nic_created_via_az_portal" {
#   name                = "${var.linux_vm_name}-nic2"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# Linux VM
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = var.linux_vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_B4ms"
  admin_username                  = var.linux_admin_username
  admin_password                  = var.linux_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.linux_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface.linux_nic]
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    ApplicationSupport = "Balraja.Dellimanickam@genpact.com"
    BusinessVertical = "Consumer and healthcare(C&H)"
    CCCode = "136"
    CustomAMI = "Not Applicable"
    Department = "Finance & Accounting(F&A)"
    InstanceSchedule = "NA"
    OSSupport = "genpactsunteam@genpact.com"
    Owner = "Siddhartha.Mahanta@genpact.com"
    OwnerSupervisor = "brijesh.nayyar@genpact.com"
    PID = "91680180"
    PatchGroup = "3th Sat 10:00 AM IST"
    ProjectName = "Cora Knowledge Assist(Mars)"
    ProvisionedBy = "vipin.panchuri@genpact.com"
    ProvisionedVia = "Terraform"
    ProvisioningSR = "RITM3529884-CHG0111921"
    OSType = "Linux ubuntu 22.04"
    RI = "Pay-As-You-Go"
    Role = "Application VM"
    SDOCode = "8527"
    ServiceType = "IaaS"
    Stack = "UAT"
    exception = "No"
    supportcost = "0$"
	  Backup = "Daily"
  }
  identity {
    type = "SystemAssigned"
  }

}

#Managed Disk
resource "azurerm_managed_disk" "linux_mdisk" {
  name                 = "${var.linux_disk_name}-${count.index + 1}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
  tags = {
    ProvisionedVia = "Terraform"
  }
  lifecycle {
    ignore_changes = [tags]

  }
  count = var.linux_datadisk_count
}


# Managed Disk attachment to VM
resource "azurerm_virtual_machine_data_disk_attachment" "linux_vm_mdisk_att" {
  managed_disk_id    = azurerm_managed_disk.linux_mdisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm.id
  lun                = count.index + 10
  caching            = "ReadWrite"
  count              = var.linux_datadisk_count
  depends_on         = [azurerm_linux_virtual_machine.linux_vm, azurerm_managed_disk.linux_mdisk]
}

# NSG for VM
resource "azurerm_network_security_group" "linux_nsg" {
  name                = var.linux_nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "Allow_Inbound_TCP_Jump_Ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [2289,22]
    source_address_prefixes      = ["10.249.130.7","10.249.130.6"]
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_TCP_LM_Ports"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135","445","139","80","443","49152-65535","1025-5000","5433","5432"]
    source_address_prefixes      = ["10.249.130.8"]
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_UDP_LM_Ports"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["161","80","443","49152-65535","1025-5000","5433","5432"]
    source_address_prefixes      = ["10.249.130.8"]
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_TCP_SAM_Ports"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["2289"]
    source_address_prefix      = "10.249.132.10"
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_ICMP_SAM_Ports"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range    = "*"
    source_address_prefix      = "10.249.132.10"
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  security_rule {
    name                       = "Deny_All_Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.linux_nic.private_ip_address
  }
  lifecycle {
    ignore_changes = [tags]

  }
}

# NIC and NSG Association
resource "azurerm_network_interface_security_group_association" "linux_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.linux_nic.id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
  depends_on                = [azurerm_network_interface.linux_nic, azurerm_network_security_group.linux_nsg]
}
