output "connection_string" {
  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}
