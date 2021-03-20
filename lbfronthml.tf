//Cria um Load Balancer externo
resource "azurerm_lb" "lab" {
  name                = "nlb-web-hml"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard" # Basic is free, but doesn't support Availability Zones
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lab.id
  }
}

resource "azurerm_public_ip" "lab" {
  name                = "nlb-publichml-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = "hml-projeto"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard"
}


resource "azurerm_lb_backend_address_pool" "backendpool" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lab.id
  name                = "BackEndAddressPool"
}

#resource "azurerm_lb_nat_pool" "natpool" {
  #resource_group_name            = azurerm_resource_group.lab.name
  #name                           = "ssh"
  #loadbalancer_id                = azurerm_lb.lab.id
  #protocol                       = "Tcp"
  #frontend_port_start            = 50000
  #frontend_port_end              = 50119
  #backend_port                   = 20
  #frontend_ip_configuration_name = "PublicIPAddress"
#}

resource "azurerm_lb_probe" "lab" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lab.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "lab" {
  resource_group_name            = azurerm_resource_group.lab.name
  loadbalancer_id                = azurerm_lb.lab.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.lab.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backendpool.id
}

