resource "azurerm_public_ip" "bastonip" {
  name                = "baston-public-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "bastonnic" {
  name                = "baston-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = var.azurerm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastonip.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                  = "baston-vm"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.bastonnic.id]
  size                  = "Standard_DS1_v2"

  admin_username = "exampleadmin"
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
