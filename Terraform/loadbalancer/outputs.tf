output "backend_pool_id" {
  description = "The ID of the loadbalancer backend pool"
  value       = azurerm_lb_backend_address_pool.lb_backend_pool.id
}
