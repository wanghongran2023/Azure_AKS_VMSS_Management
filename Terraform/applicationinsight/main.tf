resource "azurerm_log_analytics_solution" "appinsights" {
  name                = "${var.resource_header}-appinsights"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  workspace_resource_id = var.log_analytics_workspace_id
  workspace_name        = var.log_analytics_workspace_name

  plan {
    product = "OMSGallery/VMInsights"
    publisher = "Microsoft"
  }
}
