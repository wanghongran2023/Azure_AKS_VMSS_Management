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

data "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_config.name
}

module "network" {
  source = "./network"
  resource_group_name=data.azurerm_resource_group.resource_group.name
  resource_group_location=data.azurerm_resource_group.resource_group.location
  resource_header="wangudacity-vmss"
}

module "loadbalancer" {
  source = "./loadbalancer"
  resource_group_name=data.azurerm_resource_group.resource_group.name
  resource_group_location=data.azurerm_resource_group.resource_group.location
  resource_header="wangudacity-vmss"
}

module "storageaccount" {
  source = "./storageaccount"
  resource_group_name=data.azurerm_resource_group.resource_group.name
  resource_group_location=data.azurerm_resource_group.resource_group.location
  resource_header="wangudacity"
}

module "aks" {
  source = "./aks"
  resource_group_name=data.azurerm_resource_group.resource_group.name
  resource_group_location=data.azurerm_resource_group.resource_group.location
  resource_header="wangudacity"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "udacity-vmss"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  admin_username       = "myadmin"
  admin_password       = "MyP@ssw0rd123!"
  instances            = 2
  sku                  = "Standard_DS1_v2"

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

  custom_data = base64encode(<<-EOT
    package_upgrade: true
    packages:
      - nginx
      - python3-pip
      - unzip
      - redis-server
    write_files:
      - owner: www-data:www-data
        path: /etc/nginx/sites-available/reverse-proxy.conf
        content: |
          server {
            listen 80;
            location / {
              proxy_pass http://localhost:5000;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection keep-alive;
              proxy_set_header Host $host;
              proxy_cache_bypass $http_upgrade;
            }
          }
    runcmd:
      - sudo unlink /etc/nginx/sites-enabled/default
      - sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
      - sudo service nginx restart
    EOT
  )

  network_interface {
    name     = "vmss-nic"
    primary  = true

    ip_configuration {
      name                                   = "vmss-ip-config"
      primary                                = true
      subnet_id                              = module.network.subnet_id
      load_balancer_backend_address_pool_ids = [module.loadbalancer.backend_address_pool[0].id]
    }
  }

  extension {
    name                 = "InstallNGINX"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    settings = jsonencode({
      commandToExecute = "git clone https://github.com/wanghongran2023/Azure_AKS_VMSS_Management.git && cd Azure_AKS_VMSS_Management && sh setup.sh"
    })
  }

  tags = {
    environment = "Test"
  }
}
