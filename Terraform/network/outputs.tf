output "subnet_id" {
  description = "The ID of the virtual network subnet"
  value       = azurerm_subnet.subnet.id
}
