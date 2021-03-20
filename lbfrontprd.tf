resource "azurerm_lb" "lb" {
  name                = "nlb-web-prd"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard" # Basic is free, but doesn't support Availability Zones
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  frontend_ip_configuration {
    name                 = "PublicIPAddressPRD"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_public_ip" "lb" {
  name                = "nlb-public-prd-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = "prd-projeto"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard"
}


resource "azurerm_lb_backend_address_pool" "backendpoolFront" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPoolPRD"
}

#resource "azurerm_lb_nat_pool" "natpoolprd" {
  //Cria um Load Balancer externo
  #resource_group_name            = azurerm_resource_group.lab.name
  #name                           = "ssh"
  #loadbalancer_id                = azurerm_lb.lb.id
  #protocol                       = "Tcp"
  #frontend_port_start            = 50000
  #frontend_port_end              = 50119
  #backend_port                   = 22
  #frontend_ip_configuration_name = "PublicIPAddressPRD"
#}

resource "azurerm_lb_probe" "lb" {
  resource_group_name = azurerm_resource_group.lab.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http-probeprd"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "lb" {
  resource_group_name            = azurerm_resource_group.lab.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRuleprd"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddressPRD"
  probe_id                       = azurerm_lb_probe.lb.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backendpoolFront.id
}

