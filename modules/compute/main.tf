resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "devops-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ic-devops"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
    
  }
}

resource "azurerm_linux_virtual_machine" "vm-lx" {
  # checkov:skip=CKV_AZURE_1: "Using admin password just for education purpose"
  # checkov:skip=CKV_AZURE_149: "Using admin password just for education purpose"
  # checkov:skip=CKV_AZURE_50: "Extensions are just for education purpose"
  # checkov:skip=CKV_AZURE_178: "SSH are not needed for this project"

  count               = 2
  zone                = tostring(count.index + 1)
  name                = "vm-devops-project-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ats_V2"
  admin_username      = "adminuser"
  disable_password_authentication = false
  admin_password = var.vm_admin_password
  

  # Skrypt instalujący prosty serwer Apache i generujący unikalny napis dla każdej maszyny
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>To maszyna nr: ${count.index}</h1>" | sudo tee /var/www/html/index.html
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


resource "azurerm_network_interface_backend_address_pool_association" "nicLB" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "ic-devops"
  backend_address_pool_id = var.backend_pool_id
}
