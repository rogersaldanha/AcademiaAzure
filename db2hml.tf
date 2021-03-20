//Cria um Interface e IP publico

#resource "azurerm_public_ip" "pipdb2" {
  #name                = "pip-vm-dbhml-02"
  #location            = var.location
  #resource_group_name = azurerm_resource_group.lab.name
  #allocation_method   = "Dynamic"

#}
resource "azurerm_network_interface" "nicdb2" {
  name                = "nic-vm-dbhml-02"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "ip-vm-dbhml-02"
    subnet_id                     = azurerm_subnet.labsnet2.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.pipdb2.id

  }

}
//Criar uma VM
resource "azurerm_windows_virtual_machine" "lab2" {
  name                = "vm-db-hml-02"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nicdb2.id,
  ]
  availability_set_id = azurerm_availability_set.lab.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2017-WS2016"
    sku       = "SQLDEV"
    version   = "latest"
  }
}
//Associa a NIC da VM ao Load Balancer
  resource "azurerm_network_interface_backend_address_pool_association" "lab2" {
  network_interface_id    = azurerm_network_interface.nicdb2.id
  ip_configuration_name   = "ip-vm-dbhml-02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpooldb1.id
}