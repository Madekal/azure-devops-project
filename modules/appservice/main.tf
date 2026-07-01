resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_container_registry" "acr" {
  name                = "webappacr${random_integer.ri.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
 
}


resource "azurerm_service_plan" "apsp" {
  name                = "webappasps${random_integer.ri.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "alp" {
  name                = "webappalp${random_integer.ri.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.apsp.id
    

  site_config {
    application_stack {
      docker_image_name             = "moja-strona:latest"
      docker_registry_url           = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username      = azurerm_container_registry.acr.admin_username
      docker_registry_password        = azurerm_container_registry.acr.admin_password
  }
}
}

#----------- GRAFANA ------------------

resource "azurerm_service_plan" "apsp2" {
  name                = "grafana${random_integer.ri.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "alp2" {
  name                = "grafana${random_integer.ri.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.apsp2.id
    

  site_config {
    application_stack {
      docker_image_name             = "grafana:latest"
      docker_registry_url           = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username      = azurerm_container_registry.acr.admin_username
      docker_registry_password        = azurerm_container_registry.acr.admin_password
  }
}

 app_settings = {
    "GF_SERVER_ROOT_URL"        = "https://grafana-${random_integer.ri.result}.azurewebsites.net"
    "GF_SECURITY_ADMIN_PASSWORD" = "AdminPassword123!"
  }


}


