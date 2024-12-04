terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  subscription_id = var.provider_credentials.subscription_id
  tenant_id       = var.provider_credentials.tenant_id
  client_id       = var.provider_credentials.sp_client_id
  client_secret   = var.provider_credentials.sp_client_secret
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_config.name
  location = var.resource_group_config.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "udacity-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "udacity-vmss-vnet-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  network_security_group_id = azurerm_network_security_group.nsg.id
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "udacity-vmss-nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "vmss-lb-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "udacity-vmss-lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name                = "udacity-vmss-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_http_probe" {
  name                = "udacity-vmss-http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_http_rule" {
  name                           = "udacity-vmss-http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_http_probe.id
}




resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "udacity-vmss"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  admin_username       = "myadmin"
  admin_password       = "MyP@ssw0rd123!"

  instances = 2
  sku       = "Standard_DS1_v2"

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

  disable_password_authentication = false

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "vmss-ip-config"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
    }
  }

  extension {
    name                 = "InstallNGINX"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
      {
        "commandToExecute": "sudo apt-get update && sudo apt-get install -y nginx"
      }
    SETTINGS
  }

  tags = {
    environment = "Test"
  }
}
