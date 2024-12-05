resource "azurerm_storage_account" "storage_account" {
  name                     = "storageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Locally-redundant storage (LRS)

  tags = {
    environment = "Test"
  }
}
