# DB VM
variable "tech501-yahya-db-prefix" {
  default = "tech501-yahya-2-tier"
}
data "azurerm_resource_group" "tech501-yahya-rg" {
  name = "tech501"

}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name
}
data "azurerm_subnet" "tech501-yahya-private-subnet" {
  name                 = "private-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.tech501-yahya-rg.name
}

resource "azurerm_network_interface" "db-Nic" {
  name                = "${var.tech501-yahya-db-prefix}-db-nic"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name

  ip_configuration {
    name                          = "db-NIC-Ip"
    subnet_id                     = data.azurerm_subnet.tech501-yahya-private-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
data "azurerm_ssh_public_key" "ssh-key" {
  name                = "tech-501-yahya-az-key"
  resource_group_name = "tech501"
}

data "azurerm_image" "tech501-yahya-sparta-db-img" {
  name                = "tech501-ramon-sparta-app-ready-to-run-db"
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name
}

resource "azurerm_linux_virtual_machine" "tech501-yahya-terraform-db-vm" {
  name  = "${var.tech501-yahya-db-prefix}-db-vm"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids         = [azurerm_network_interface.db-Nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/Users/yahmoham1/.sshkey/tech501-yahya-az-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "/subscriptions/subscriptionID/resourceGroups/tech501/providers/Microsoft.Compute/images/tech501-ramon-sparta-app-ready-to-run-db"


  tags = {
    owner = "yahya"
  }

}





#APP VM
variable "tech501-yahya-app-prefix" {
  default = "tech501-yahya-2-tier"
}

data "azurerm_virtual_network" "tech501-yahya-vnet" {
  name                = var.vnet-name
  resource_group_name  = data.azurerm_resource_group.tech501-yahya-rg.name

}
data "azurerm_subnet" "tech501-yahya-public-subnet" {
  name                 = "public-subnet"
  virtual_network_name = data.azurerm_virtual_network.tech501-yahya-vnet.name
  resource_group_name  = data.azurerm_resource_group.tech501-yahya-rg.name
}

resource "azurerm_network_interface" "app-NIC" {
  name                = "${var.tech501-yahya-app-prefix}-app-nic"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name

  ip_configuration {
    name                          = "app-NIC-Ip"
    subnet_id                     = data.azurerm_subnet.tech501-yahya-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tech501-yahya-sparta-public-ip.id

  }
}
resource "azurerm_public_ip" "tech501-yahya-sparta-public-ip" {
  name                = "${var.tech501-yahya-app-prefix}-public-ip"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name
  allocation_method   = "Dynamic" # or "Static" if you require a fixed IP
  sku                 = "Basic"   # or "Standard" depending on your needs
}


resource "azurerm_network_security_group" "tech-501-yahya-nsg" {
  name                = "${var.tech501-yahya-app-prefix}-nsg"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name

  
  # Allow SSH (port 22)
  security_rule {
    name                       = "allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP (port 80)
  security_rule {
    name                       = "allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_network_interface_security_group_association" "tech-501-yahya-nsg-association" {
  network_interface_id      = azurerm_network_interface.app-NIC.id
  network_security_group_id = azurerm_network_security_group.tech-501-yahya-nsg.id
}


data "azurerm_ssh_public_key" "tech-501-yahya-az-key" {
  name                = "tech-501-yahya-az-key"
  resource_group_name = "tech501"
}




resource "azurerm_linux_virtual_machine" "tech501-yahya-terraform-app-vm" {
  name  = "${var.tech501-yahya-app-prefix}-app-vm"
  location            = data.azurerm_resource_group.tech501-yahya-rg.location
  resource_group_name = data.azurerm_resource_group.tech501-yahya-rg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids         = [azurerm_network_interface.app-NIC.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/Users/yahmoham1/.sshkey/tech501-yahya-az-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 custom_data = base64encode("#!/bin/bash\ncd /repo/app\nexport DB_HOST=mongodb://${azurerm_network_interface.db-Nic.private_ip_address}/posts\npm2 start app.js")


  tags = {
    owner = "yahya"
  }

  source_image_id = "/subscriptions/subscriptionID/resourceGroups/tech501/providers/Microsoft.Compute/images/tech501-ramon-sparta-test-app-ready-to-run-app"


}
