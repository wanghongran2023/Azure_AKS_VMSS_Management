output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "storage_account_primary_key" {
  value = azurerm_storage_account.example.primary_access_key
}
