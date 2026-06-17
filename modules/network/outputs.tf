output "private_subnet_id" {
  value       = azurerm_subnet.snet2.id
  description = "Private subnet ID passed to other modules"
}

output "backend_pool_id" {
  value       = azurerm_lb_backend_address_pool.lbib.id
  description = "ID backend addresses pool from Load Balancer received to machines"
}

output "log_analytics_workspace_id" {
  value = var.log_analytics_workspace_id
  description = "ID bazy Log Analytics przekazane z modułu monitoring"
}