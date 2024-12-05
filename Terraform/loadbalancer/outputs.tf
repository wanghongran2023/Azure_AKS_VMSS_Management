output "backend_pool_id" {
  description = "The ID of the loadbalancer backend pool"
  value       = azurerm_subnet.subnet.id
}
