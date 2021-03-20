//Cria uma rede para o ambiente de produção
resource "azurerm_virtual_network" "prd" {
  name                = "vnet-prd-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "prdsnet1" {
  name                 = "snet-web-prd"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.prd.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "prdsnet2" {
  name                 = "snet-bd-prd"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.prd.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_network_security_group" "prdnsgweb" {
  name                = "nsg-web-prd"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
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

resource "azurerm_subnet_network_security_group_association" "prdnsg1" {
  subnet_id                 = azurerm_subnet.prdsnet1.id
  network_security_group_id = azurerm_network_security_group.prdnsgweb.id
}

resource "azurerm_network_security_group" "prdnsgdb" {
    name                = "nsg-db-prd"
    location            = var.location
    resource_group_name = azurerm_resource_group.lab.name
         security_rule {
    name                       = "Deny_All"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

        security_rule {
    name                       = "Allow_RDP_Jumper"
    priority                   = 999
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "172.16.2.4"
    destination_address_prefix = "*"
  }
          security_rule {
    name                       = "Allow_SQL_1433"
    priority                   = 998
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "192.168.1.0/24"
    destination_address_prefix = "*"
  }
            security_rule {
    name                       = "Allow_ADDS"
    priority                   = 997
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.1.4"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "prdnsg2" {
  subnet_id                 = azurerm_subnet.prdsnet2.id
  network_security_group_id = azurerm_network_security_group.prdnsgdb.id
}
