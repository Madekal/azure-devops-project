resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-project"
  location = "swedencentral"
  tags = {
    environment = "devops"
    source = "Terraform"
  }
}


#VIRTUAL NETWORK - SUBNETS - NSG  ------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops-project"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]


}


resource "azurerm_subnet" "snet1" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet2" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "nsg" {
  name                = "NSG-DevOps"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name



  security_rule {
    name                       = "allowHTTPs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


   security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "denyALL"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}



resource "azurerm_subnet_network_security_group_association" "nsa" {
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "pip" {
  name                = "PublicIPAddressProject"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

}
#STORAGE ACCOUNT ------------------------------------------

resource "azurerm_storage_account" "st" {
  name                     = "storagedevops2026project"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "tfstate"
  storage_account_name    = azurerm_storage_account.st.name
  container_access_type = "private"

}

#VIRTUAL MACHINE ------------------------------------------

resource "azurerm_network_interface" "nic" {
  name                = "devops-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ic-devops"
    subnet_id                     = azurerm_subnet.snet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "vm-devops-project"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  disable_password_authentication = "false"
  admin_password = "Kwasnejablko1234!"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
    
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}   
    