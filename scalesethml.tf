//Cria um VMSS para o ambiente de homologação, máquina de FrontEnd
resource "azurerm_virtual_machine_scale_set" "lab" {
  name                = "vmss-scalesetmhl-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.lab.id

  zones = var.zones

  sku {
    name     = "Standard_A1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "vm"
    admin_username       = "azureuser"
    admin_password       = "p@ssw0rd@2021"
    //custom_data          = "#!/bin/bash\n\napt-get update && apt-get install -y nginx && systemctl enable nginx && systemctl start nginx"
  }
    extension {
    name                 = "InstallCustomScript"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    settings             = <<SETTINGS
        {
          "fileUris": ["https://raw.githubusercontent.com/rogersaldanha/AcademiaAzure/main/install_nginx.sh"], 
          "commandToExecute": "./install_nginx.sh"
        }
      SETTINGS
  }

  os_profile_linux_config {
    disable_password_authentication = false

  }

  network_profile {
    name                      = "networkprofile"
    primary                   = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.labsnet1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
      #load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.natpool.id]
    }
  }
}
