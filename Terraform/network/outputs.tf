output "subnet_id" {
  description = "The ID of the virtual network subnet"
  value       = azurerm_virtual_network.vnet.id
}
