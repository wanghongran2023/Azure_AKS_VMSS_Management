resource "azurerm_storage_account" "storage_account" {
  name                = "${var.resource_header}-storageaccount"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Test"
  }
}
