
# Use existing Virtual Network and Subnets
data "azurerm_virtual_network" "CKA-Vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group
  depends_on = [ azurerm_virtual_network.CKA-Vnet ]
}

/*
data "azurerm_subnet" "private_subnet" {
  name                 = var.subnet_name[4]
  virtual_network_name = data.azurerm_virtual_network.CKA-Vnet
  resource_group_name  = var.resource_group
  depends_on = [ azurerm_subnet.Pvt-Sub4 ]
}*/


data "azurerm_subnet" "vm_private_subnet" {
  name                 = var.subnet_name[4]
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group
  depends_on = [azurerm_virtual_network.CKA-Vnet, azurerm_subnet.Pvt-Sub4 ]
}

resource "azurerm_network_interface" "nic" {
  name                = var.vm_Windows_nic
  location            = var.location
  resource_group_name = var.resource_group
  depends_on = [ azurerm_subnet.Pvt-Sub4 ]
  # ip_configuration {
  #   name                          = "internal"
  #   subnet_id                     = data.azurerm_subnet.private_subnet.id
  #   private_ip_address_allocation = "Dynamic"
  # }
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vm_private_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.140"
  }
  lifecycle {
    ignore_changes = [tags]

  }
}
# Mapping the NIC created via azure portal
# data "azurerm_network_interface" "win_vm_nic_created_via_az_portal" {
#   name                = "${var.win_vm_name}-nic2"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# Windows VM
resource "azurerm_windows_virtual_machine" "Win_vm" {
  name                  = var.Win_vm
  resource_group_name   = var.resource_group
  location              = var.location
  size                  = "Standard_B4ms"
  admin_username        = var.admin_usernamer
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = {
    ApplicationSupport = "Balraja.Dellimanickam@genpact.com"
    BusinessVertical = "Consumer and healthcare(C&H)"
    CCCode = "136"
    CustomAMI = "Not Applicable"
    Department = "Finance & Accounting(F&A)"
    InstanceSchedule = "NA"
    OSSupport = "genpactcomputewindowsossupport@genpact.com"
    Owner = "Siddhartha.Mahanta@genpact.com"
    OwnerSupervisor = "brijesh.nayyar@genpact.com"
    PID = "91680180"
    PatchGroup = "3th Sat 10:00 AM IST"
    ProjectName = "Cora Knowledge Assist(Mars)"
    ProvisionedBy = "vipin.panchuri@genpact.com"
    ProvisionedVia = "Terraform"
    ProvisioningSR = "RITM3529884-CHG0111921"
    OSType = "Windows Server 2022 datacenter"
    RI = "Pay-As-You-Go"
    Role = "Application VM"
    SDOCode = "8527"
    ServiceType = "IaaS"
    Stack = "UAT"
    exception = "No"
    supportcost = "0$"
	Backup = "Daily"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [azurerm_network_interface.nic]
}

#Managed Disk
resource "azurerm_managed_disk" "mdisk" {
  name                 = "${var.Win_disk_name}-${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
  count                = var.datadisk_count
  depends_on = [ azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet, azurerm_windows_virtual_machine.Win_vm ]
  lifecycle {
    ignore_changes = [tags]

  }
}


# Managed Disk attachment to VM
resource "azurerm_virtual_machine_data_disk_attachment" "vm_mdisk_att" {
  managed_disk_id    = azurerm_managed_disk.mdisk[count.index].id #azurerm_managed_disk.mdisk[count.index].id
  count              = var.datadisk_count
  virtual_machine_id = azurerm_windows_virtual_machine.Win_vm.id
  lun                = count.index + 10
  caching            = "ReadWrite"
  depends_on         = [azurerm_windows_virtual_machine.Win_vm, azurerm_managed_disk.mdisk]
}

# NSG for VM
resource "azurerm_network_security_group" "nsg" {
  name                = var.Win_nsg_name
  location            = var.location
  resource_group_name = var.resource_group
  security_rule {
    name                       = "Allow_Inbound_TCP_Jump_Ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [2289,3389]
    source_address_prefixes      = ["10.249.130.5","10.249.130.4"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_UDP_AD_Ports"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["1025-5000","123","137","138","389","445","464","49152-65535","53","88"]
    source_address_prefixes      = ["10.249.132.6","10.249.132.7"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_TCP_AD_Ports"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["1025-5000","123","137","138","389","445","464","49152-65535","53","88"]
    source_address_prefixes      = ["10.249.132.6","10.249.132.7"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_TCP_LM_Ports"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135","445","139","80","443","49152-65535","1025-5000","5433","5432"]
    source_address_prefixes      = ["10.249.130.8"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_UDP_LM_Ports"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["161","80","443","49152-65535","1025-5000","5433","5432"]
    source_address_prefixes      = ["10.249.130.8"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_Tcp_SAM_Ports"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135","445","49152-65535"]
    source_address_prefixes      = ["10.249.132.10"]
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  security_rule {
    name                       = "Allow_Inbound_ICMP_SAM_Ports"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range    = "*"
    source_address_prefix      = "10.249.132.10"
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
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
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
  lifecycle {
    ignore_changes = [tags]

  }
}

# NIC and NSG Association
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on                = [azurerm_network_interface.nic, azurerm_network_security_group.nsg]
}

