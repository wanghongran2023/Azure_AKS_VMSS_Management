resource "azurerm_public_ip" "bastionip" {
  name                = "bastion-public-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "bastionnic" {
  name                = "bastion-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastionip.id
  }
}

resource "azurerm_linux_virtual_machine" "baston" {
  name                  = "bastion-vm"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.bastionnic.id]
  size                  = "Standard_DS1_v2"

  admin_username = "myadmin"
  admin_password = "ExampleP@ssword123!!"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "Example"
  }
}
