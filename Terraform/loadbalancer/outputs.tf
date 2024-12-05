output "backend_pool_id" {
  description = "The ID of the loadbalancer backend pool"
  value       = azurerm_lb_backend_address_pool.lb_backend_pool.id
}

output "lb_http_probe" {
  description = "The ID of the lb http probe"
  value       = azurerm_lb_probe.lb_http_probe.id
}
