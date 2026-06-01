data "azurerm_log_analytics_workspace" "example" {
  name                = "analyticsLB"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  retention_in_days   = 30
}