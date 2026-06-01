resource "azurerm_storage_account" "st" {
  name                     = "storagedevops2026project"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                    = "tfstate"
  storage_account_name    = azurerm_storage_account.st.name
  container_access_type   = "private"

}

