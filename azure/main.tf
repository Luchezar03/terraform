resource "azurerm_resource_group" "main" {
  name     = "${var.env_id}-rg"
  location = var.location

  tags = var.tags
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.env_id}-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [var.vnet_cidr]

  tags = var.tags
}


resource "azurerm_network_security_group" "main" {
  name                = "${var.env_id}-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  security_rule {
    name                       = "ingress100"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ingress101"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

#region VM1
resource "azurerm_subnet" "vm1" {
  name                 = "${var.env_id}-vm1-sn"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

resource "azurerm_subnet_network_security_group_association" "vm1" {
  subnet_id                 = azurerm_subnet.vm1.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_public_ip" "vm1" {
  name                = "${var.env_id}-vm1-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  availability_zone   = var.vms.vm1["zone"]
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "vm1" {
  name                = "${var.env_id}-vm1-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "${var.env_id}-vm1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vms.vm1["size"]
  admin_username      = "yurii_pyshuk"
  admin_password      = var.user_password
  zone                = var.vms.vm1["zone"]
  network_interface_ids = [
    azurerm_network_interface.vm1.id
  ]

  os_disk {
    caching              = var.vms.vm1["caching"]
    storage_account_type = var.vms.vm1["storage_account_type"]
  }

  source_image_reference {
    publisher = var.vms.vm1["publisher"]
    offer     = var.vms.vm1["offer"]
    sku       = var.vms.vm1["sku"]
    version   = var.vms.vm1["version"]
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool_address" "vm1" {
  name                    = "vm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vms.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_windows_virtual_machine.vm1.private_ip_address
}

#endregion

#region VM2
resource "azurerm_subnet" "vm2" {
  name                 = "${var.env_id}-vm2-sn"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 10)]
}

resource "azurerm_subnet_network_security_group_association" "vm2" {
  subnet_id                 = azurerm_subnet.vm2.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_public_ip" "vm2" {
  name                = "${var.env_id}-vm2-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  availability_zone   = var.vms.vm2["zone"]
  sku                 = "Standard"


  tags = var.tags
}


resource "azurerm_network_interface" "vm2" {
  name                = "${var.env_id}-vm2-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2.id
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "${var.env_id}-vm2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vms.vm2["size"]
  admin_username      = "yurii_pyshuk"
  admin_password      = var.user_password
  zone                = var.vms.vm2["zone"]
  network_interface_ids = [
    azurerm_network_interface.vm2.id
  ]

  os_disk {
    caching              = var.vms.vm2["caching"]
    storage_account_type = var.vms.vm2["storage_account_type"]
  }

  source_image_reference {
    publisher = var.vms.vm2["publisher"]
    offer     = var.vms.vm2["offer"]
    sku       = var.vms.vm2["sku"]
    version   = var.vms.vm2["version"]
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool_address" "vm2" {
  name                    = "vm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vms.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_windows_virtual_machine.vm2.private_ip_address
}

#endregion

#region LB

resource "azurerm_public_ip" "lb" {
  name                = "${var.env_id}-lb-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_lb" "main" {
  name                = "${var.env_id}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http"
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "vms" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "vms-http"
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "Http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.vms.id
  probe_id                       = azurerm_lb_probe.http.id
}

#endregion
