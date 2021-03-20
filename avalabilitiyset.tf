//Cria um Availability Set para as VMs de Backend da Vnet de Homologação
resource "azurerm_availability_set" "lab" {
  name                = "aset-hml"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
 
}

//Cria um Availability Set para as VMs de Backend da Vnet de Produção
resource "azurerm_availability_set" "avasetprd" {
  name                = "aset-prd"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}