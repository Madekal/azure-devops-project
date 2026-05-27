resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-project"
  location = "switzerlandnorth"
  tags = {
    environment = "devops"
    source = "Terraform"
  }
}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops-project"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]


  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

    subnet {
    name             = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
  }

}


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
