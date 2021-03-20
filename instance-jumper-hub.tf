//Criar um indereço IP Publico para a VM

resource "azurerm_public_ip" "pipjumper" {
  name                = "pip-vm-jumper-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Dynamic"

}
//Criar uma Interce de rede para a VM
resource "azurerm_network_interface" "nicjumper" {
  name                = "nic-vm-jumper-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "ip-vm-jumper-01"
    subnet_id                     = azurerm_subnet.hubsnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipjumper.id

  }

}


//Criar uma VM
resource "azurerm_windows_virtual_machine" "vmjumper" {
  name                = "vm-jumper-01"
  resource_group_name = azurerm_resource_group.lab.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nicjumper.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}