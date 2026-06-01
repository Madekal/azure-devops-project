variable "resource_group_name" {
  type        = string
  description = "Name from main resource group"
}

variable "location" {
  type        = string
  description = "Location from main resource group"
}


variable "log_analytics_workspace_id" {
  type        = string
  description = "ID bazy Log Analytics przekazane z modułu monitoring"
}