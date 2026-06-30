resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-project"
  location = "swedencentral"
  tags = {
    environment = "devops"
    source = "Terraform"
  }
}

module "network" {
  source                      = "./modules/network"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  log_analytics_workspace_id  = module.monitoring.log_analytics_workspace_id
}


# Random password for VM deploy -------------------

resource "random_password" "vm_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
# -------------------------------------------------

module "compute" {
  source                = "./modules/compute"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  private_subnet_id     = module.network.private_subnet_id
  vm_admin_password     = random_password.vm_admin_password.result
  backend_pool_id       = module.network.backend_pool_id
}

#module "storage" {
 # source                = "./modules/storage"
 # location              = azurerm_resource_group.rg.location
 # resource_group_name   = azurerm_resource_group.rg.name
#}

module "monitoring" {
  source                = "./modules/monitoring"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name

}

module "appservice" {
  source = "./modules/appservice"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}