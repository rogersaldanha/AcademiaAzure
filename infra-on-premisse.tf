//Este arquivo cria uma Infra simulando um abiemte local com uma Vnet
//Uma Subnet para o Gateway de VPN
//Uma Subnet para as VMS
//Uma conexão com nossa rede HUB simulando uma VPN Onpremisses to Cloud
//Uma máquina Virtual


//Criar o grupo de recursos do Ambiente simulado Local
resource "azurerm_resource_group" "onpremise" {
  name     = "rg-projeto-onpremise-eastus2"
  location = "eastus2"
}
//Criar uma Vnet
resource "azurerm_virtual_network" "onpremise" {
  name                = "vnet-on-premise"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name
  address_space       = ["10.100.0.0/16"]
}
//Criar uma Subnet para o GW de VPN
resource "azurerm_subnet" "eastus2_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.onpremise.name
  virtual_network_name = azurerm_virtual_network.onpremise.name
  address_prefixes     = ["10.100.1.0/24"]
}
//Cria uma Subnet para VMs
resource "azurerm_subnet" "eastus2_onpremise" {
  name                 = "snet-onpremise"
  resource_group_name  = azurerm_resource_group.onpremise.name
  virtual_network_name = azurerm_virtual_network.onpremise.name
  address_prefixes     = ["10.100.2.0/24"]
}
//Criar uma NSG que será anexada a Subnet de VMs
  resource "azurerm_network_security_group" "onpremisseNSG" {
  name                = "nsg-web-prd"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name
//Regra liberando conexões RDP a Subnet de VMs
  security_rule {
    name                       = "RDP_Allow"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  }
  //Associa a NSG a Subnet
resource "azurerm_subnet_network_security_group_association" "onnsg1" {
  subnet_id                 = azurerm_subnet.eastus2_onpremise.id
  network_security_group_id = azurerm_network_security_group.onpremisseNSG.id
}

//Cria um IP Publico para o Gateway de rede Virtual
resource "azurerm_public_ip" "piponpremise" {
  name                = "pip-onpremise-gw"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name
  allocation_method   = "Dynamic"
}
//Cria um Gateway de rede Virtual para as VPNs
resource "azurerm_virtual_network_gateway" "gwonpremise" {
  name                = "gw-onpremise-eastus2"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "Basic"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.piponpremise.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.eastus2_gateway.id
  }
}

//Criar uma conexão na ponta "Cloud"
resource "azurerm_virtual_network_gateway_connection" "us_to_us2" {
  name                = "us-to-us2"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.gw.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.gwonpremise.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

//Criar uma conexão na ponta "on-premise"
resource "azurerm_virtual_network_gateway_connection" "us2_to_us" {
  name                = "us2-to-us"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.gwonpremise.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.gw.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

//Criar um indereço IP Publico VM ONPREMISE

resource "azurerm_public_ip" "pipvmonpremise01" {
  name                = "pip-vmonpremise-01"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name
  allocation_method   = "Dynamic"

}
//Criar uma Interce de rede para a VM Onpremise
resource "azurerm_network_interface" "niconpremise" {
  name                = "nic-vm-onpremise-01"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name

  ip_configuration {
    name                          = "ip-vm-onpremise-01"
    subnet_id                     = azurerm_subnet.eastus2_onpremise.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipvmonpremise01.id

  }

}


//Criar uma VM ON-PREMISE


resource "azurerm_windows_virtual_machine" "vmonpremise" {
  name                = "vm-onpremise-01"
  resource_group_name = azurerm_resource_group.onpremise.name
  location            = azurerm_resource_group.onpremise.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.niconpremise.id,
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