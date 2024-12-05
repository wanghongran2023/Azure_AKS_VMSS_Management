resource "azurerm_application_insights" "appinsights" {
  name                = "${var.resource_header}-appinsights"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_resource_id = var.log_analytics_workspace_id
  workspace_name        = var.log_analytics_workspace_name

  tags = {
    environment = "test"
  }
}
