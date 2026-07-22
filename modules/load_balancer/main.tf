resource "azurerm_public_ip" "lb_pip" {
  name                = "-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "k8s_lb" {
  name                = "-k8s-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "k8s-backend-pool"
  loadbalancer_id = azurerm_lb.k8s_lb.id
}

resource "azurerm_lb_probe" "k8s_api_probe" {
  name                = "k8s-api-probe"
  loadbalancer_id     = azurerm_lb.k8s_lb.id
  protocol            = "Tcp"
  port                = 6443
}

resource "azurerm_lb_rule" "k8s_api_rule" {
  name                           = "k8s-api-rule"
  loadbalancer_id                = azurerm_lb.k8s_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.k8s_api_probe.id
}
