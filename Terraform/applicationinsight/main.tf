resource "azurerm_application_insights" "appinsights" {
  name                = "${var.resource_header}-appinsights"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = {
    environment = "test"
  }
}
