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


resource "azurerm_public_ip" "lb_pip" {
  name                = "PublicIPAddressProjectLB"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku = "Standard"

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
  count               = 2
  name                = "devops-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ic-devops"
    subnet_id                     = azurerm_subnet.snet1.id
    private_ip_address_allocation = "Dynamic"
    
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  count               = 2
  name                = "vm-devops-project-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_V2"
  admin_username      = "adminuser"
  disable_password_authentication = false
  admin_password = "Kwasnejablko1234!"
  

  # Skrypt instalujący prosty serwer Apache i generujący unikalny napis dla każdej maszyny
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Witaj z maszyny nr: ${count.index}</h1>" | sudo tee /var/www/html/index.html
              EOF
  )



  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
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
    

#LOAD BALACNER ----------------------------------

resource "azurerm_lb" "lbi" {
  name                = "LoadBalancerProject"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbib" {
  loadbalancer_id = azurerm_lb.lbi.id
  name            = "BackEndAddressPool"
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lbi.id
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbib.id]
}


resource "azurerm_network_interface_backend_address_pool_association" "nicLB" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbib.id
}