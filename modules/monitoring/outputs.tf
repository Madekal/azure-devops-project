output "log_analytics_workspace_id" {
  value = data.azurerm_log_analytics_workspace.log.workspace_id
  description = "Log Analytics database ID used for diagnostic settings"
}