//Cria um Load Balancer Interno
resource "azurerm_lb" "lab1" {
  name                = "nlb-db-hml"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard" # Basic is free, but doesn't support Availability Zones
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  frontend_ip_configuration {
    name                          = "PrivateAdress"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.200"
    subnet_id                     = azurerm_subnet.labsnet2.id
    #public_ip_address_id = azurerm_public_ip.lab.id
  }
}

#resource "azurerm_public_ip" "lab" {
#name                = "nlb-publichml-ip"
#location            = var.location
#resource_group_name = azurerm_resource_group.lab.name
#allocation_method   = "Static"
#domain_name_label   = azurerm_resource_group.lab.name
#sku                 = length(var.zones) == 0 ? "Basic" : "Standard"
#}


resource "azurerm_lb_backend_address_pool" "backendpooldb1" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lab1.id
  name                = "BackEndAddressPool1"
}

#resource "azurerm_lb_backend_address_pool" "backendpooldb2" {
#  resource_group_name = azurerm_resource_group.lab.name
#  loadbalancer_id     = azurerm_lb.lab1.id
#  name                = "BackEndAddressPool2"
#}

#resource "azurerm_lb_nat_pool" "natpooldb" {
 # resource_group_name            = azurerm_resource_group.lab.name
  #name                           = "sql"
  #loadbalancer_id                = azurerm_lb.lab.id
  #protocol                       = "Tcp"
  #frontend_port_start            = 50000
  #frontend_port_end              = 50119
  #backend_port                   = 1433
  #frontend_ip_configuration_name = "PrivateAdress"
#}

resource "azurerm_lb_probe" "lab1" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lab1.id
  name                = "sql-probe"
  protocol            = "tcp"
  #request_path        = "/"
  port                = 1433
}

resource "azurerm_lb_rule" "lab1" {
  resource_group_name            = azurerm_resource_group.lab.name
  loadbalancer_id                = azurerm_lb.lab1.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = "PrivateAdress"
  probe_id                       = azurerm_lb_probe.lab1.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backendpooldb1.id
}
