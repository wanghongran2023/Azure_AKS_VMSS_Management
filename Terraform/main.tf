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

data "azurerm_log_analytics_workspace" "example" {
  name                = "loganalytics-270342"
  resource_group_name = "cloud-demo"
}

module "network" {
  source = "./network"
  resource_group_name=azurerm_resource_group.resource_group.name
  resource_group_location=azurerm_resource_group.resource_group.location
  resource_header="wangudacity-vmss"
}

module "loadbalancer" {
  source = "./loadbalancer"
  resource_group_name=azurerm_resource_group.resource_group.name
  resource_group_location=azurerm_resource_group.resource_group.location
  resource_header="wangudacity-vmss"
}

module "applicationinsight" {
  source = "./applicationinsight"
  resource_group_name=azurerm_resource_group.resource_group.name
  resource_group_location=azurerm_resource_group.resource_group.location
  resource_header="wangudacity-vmss"
  log_analytics_workspace_id=data.azurerm_log_analytics_workspace.example.id
  log_analytics_workspace_name=data.azurerm_log_analytics_workspace.example.name
}

module "storageaccount" {
  source = "./storageaccount"
  resource_group_name=azurerm_resource_group.resource_group.name
  resource_group_location=azurerm_resource_group.resource_group.location
  resource_header="wangudacity"
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
    name="vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "vmss-ip-config"
      primary                                = true
      subnet_id                              = module.network.subnet_id
      load_balancer_backend_address_pool_ids = [module.loadbalancer.backend_pool_id]
    }
  }

  extension {
    name                 = "InstallNGINX"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = jsonencode({
      commandToExecute = "sudo apt update && sudo apt install -y nginx"
    })
  }


  tags = {
    environment = "Test"
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "vmss_ext_mma" {
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  auto_upgrade_minor_version   = true
  name                         = "MicrosoftMonitoringAgent"
  publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
  type                         = "MicrosoftMonitoringAgent"
  type_handler_version         = "1.0"
  
  protected_settings = jsonencode({
    "workspaceKey" = "${data.azurerm_log_analytics_workspace.example.primary_shared_key}"
  })

  settings = jsonencode({
    "workspaceId"               = "${data.azurerm_log_analytics_workspace.example.id}",
    "stopOnMultipleConnections" = true
  })
}

resource "azurerm_virtual_machine_scale_set_extension" "vmss_ext_da" {
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  auto_upgrade_minor_version   = true
  name                         = "DependencyAgentLinux"
  publisher                    = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                         = "DependencyAgentWindows"
  type_handler_version         = "9.10"
  provision_after_extensions = [azurerm_virtual_machine_scale_set_extension.vmss_ext_mma.name]

  settings = jsonencode({
    "enableAutomaticUpgrade" = true
  })
}
