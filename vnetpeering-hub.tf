//Configura os Peering entre as Vnets Hub,Homologação E Produção
resource "azurerm_virtual_network_peering" "peer-1" {
  name                      = "peer-vnethml-vnethub"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.lab.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer-2" {
  name                      = "peer-vnethub-vnethml"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.lab.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "peer-3" {
  name                      = "peer-vnethub-vnetprd"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.prd.id
  allow_virtual_network_access = true
  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "peer-4" {
  name                      = "peer-vnetprd-vnethub"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.prd.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
}