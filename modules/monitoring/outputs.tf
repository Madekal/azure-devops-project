output "log_analytics_workspace_id" {
  value =   azurerm_log_analytics_workspace.log.id
  description = "Log Analytics database ID used for diagnostic settings"
}