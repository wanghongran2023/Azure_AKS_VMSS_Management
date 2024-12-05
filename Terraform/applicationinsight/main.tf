resource "azurerm_application_insights" "example" {
  name                = "${var.resource_header}-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"

  # Optional tags
  tags = {
    environment = "development"
  }
}
