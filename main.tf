provider "azurerm" {
  features {}
}

data "azurerm_image" "main" {
  name                = "ubuntuImage"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_resource_group" "main" {
  name = "Azuredevops"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  tags = {
    udacity = var.commonTagName
  }
}

# Rule to deny all inbound traffic from the internet
resource "azurerm_network_security_rule" "deny_internet_inbound" {
  name                        = "deny-internet-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
}

# Rule allowing inbound traffic inside the same Virtual Network
resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  name                        = "allow-vnet-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.main.name
}

# Rule allowing outbound traffic inside the same Virtual Network
resource "azurerm_network_security_rule" "allow_vnet_outbound" {
  name                        = "allow-vnet-outbound"
  priority                    = 300
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.main.name
}

# Rule allowing HTTP traffic to the VMs from the load balancer
resource "azurerm_network_security_rule" "allow_http_from_lb" {
  name                        = "allow-http-from-lb"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = azurerm_lb.main.frontend_ip_configuration
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_interface" "main" {
  count               = var.virtualMachineCount
  name                = "${var.prefix}-nic-${count.index}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-ipconf-${count.index}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                          = "${var.prefix}-frontend-ip"
    public_ip_address_id          = azurerm_public_ip.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.prefix}-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.virtualMachineCount
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-ipconf-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_managed_disk" "main" {
  count                = var.virtualMachineCount
  name                 = "${var.prefix}-mndisk-${count.index}"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    udacity = var.commonTagName
  }
}

resource "azurerm_virtual_machine" "main" {
  count                 = var.virtualMachineCount
  name                  = "${var.prefix}-vm-${count.index}"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = data.azurerm_image.main.id
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.main.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.main.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.main.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "${var.prefix}-hostname"
    admin_username = "adminUcacity"
    admin_password = "Admin123456!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    udacity = var.commonTagName
  }
}
