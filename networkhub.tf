//Cria a rede HUB Compartilhada
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "hubsnet1" {
  name                 = "snet-hub-shared"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.16.1.0/24"]
}

//VNET do Gateway VPN
resource "azurerm_subnet" "hubsnet2" {
  name                 = "snet-hub-jumper"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.16.2.0/24"]
}

//Virtual Network Gateway Subnet
resource "azurerm_subnet" "hubsnet3" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.16.200.0/24"]
}

//Public IP Gateway
resource "azurerm_public_ip" "pipgw" {
  name                = "pip-hub-gw-01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  allocation_method = "Dynamic"
}

//Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "gw" {
  name                = "gw-hub-shared"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pipgw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hubsnet3.id
  }
}

//Criar NSG para Subnet HUB snet-hub-shared
resource "azurerm_network_security_group" "hubnsgsnet1" {
    name                = "nsg-hub-shared"
    location            = var.location
    resource_group_name = azurerm_resource_group.lab.name
}


resource "azurerm_network_security_group" "hubnsgsnet2" {
  name                = "nsg-hub-jumper"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.rdp-source-address
    destination_address_prefix = "*"
  }
    #security_rule {
    #name                       = "SSH"
    #priority                   = 1002
    #direction                  = "Inbound"
    #access                     = "Allow"
    #protocol                   = "Tcp"
    #source_port_range          = "*"
    #destination_port_range     = "22"
    #source_address_prefix      = var.ssh-source-address
    #destination_address_prefix = "*"
  #}
}


resource "azurerm_subnet_network_security_group_association" "nsg1" {
  subnet_id                 = azurerm_subnet.hubsnet1.id
  network_security_group_id = azurerm_network_security_group.hubnsgsnet1.id
}

resource "azurerm_subnet_network_security_group_association" "nsg2" {
  subnet_id                 = azurerm_subnet.hubsnet2.id
  network_security_group_id = azurerm_network_security_group.hubnsgsnet2.id
}
