output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
  sensitive = true
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
  sensitive = true
}
