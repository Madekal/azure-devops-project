resource "azurerm_log_analytics_workspace" "log" {
  name                = "analyticsLB"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_monitor_data_collection_rule" "mdcr" {
  name                        = "vm-metrics"
  resource_group_name         = var.resource_group_name
  location                    = var.location

  destinations {
    log_analytics {
      workspace_resource_id  = azurerm_log_analytics_workspace.log
      name                   = "destination-log"
    }
  }
  

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["destination-log"]
  }

    data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\Processor(_Total)\\% Processor Time", "\\Memory\\% Committed Bytes In Use"]
      name                           = "perfCounters"
    }
}

}


