resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops-project"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]


}


resource "azurerm_subnet" "snet1" {
  name                 = "public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet2" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "nsg" {
  name                = "NSG-DevOps"
  location            = var.location
  resource_group_name = var.resource_group_name



  security_rule {
    # checkov:skip=CKV_AZURE_160: "HTTP (port 80) must be public, beacause of Load Balancer in this project"
    name                       = "allowHTTPs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


   security_rule {
    name                        = "AllowSSH"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    
  }


  security_rule {
    name                       = "denyALL"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}



resource "azurerm_subnet_network_security_group_association" "nsa" {
  subnet_id                 = azurerm_subnet.snet2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsa_public" {
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb_pip" {
  name                = "PublicIPAddressProjectLB"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
  domain_name_label   = "projekt-devops-2k26"

}


resource "azurerm_lb" "lbi" {
  name                = "LoadBalancerProject"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbib" {
  loadbalancer_id = azurerm_lb.lbi.id
  name            = "BackEndAddressPool"
 
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lbi.id
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbib.id]
  probe_id                       = azurerm_lb_probe.lbp.id
}



resource "azurerm_lb_probe" "lbp" {
  loadbalancer_id     = azurerm_lb.lbi.id
  name                = "ssh-health-probe"
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2

}

#DNS --------------------------------------------------

#resource "azurerm_dns_zone" "DNS_DevOpsProjectDK" {
  #name                = "devopsdk.pl"
  #resource_group_name = var.resource_group_name
#}

#resource "azurerm_dns_a_record" "DNS_Name" {
 # name                = "project"
  #zone_name           = azurerm_dns_zone.DNS_DevOpsProjectDK.name
  #resource_group_name = var.resource_group_name
  #ttl                 = 300
  #records             = [azurerm_public_ip.lb_pip.ip_address]
#}


# MONITORING DIAGNOSTIC SETTINGS ------------------------

resource "azurerm_monitor_diagnostic_setting" "lb_diagnostic" {
  name                       = "ds-load-balancer"
  target_resource_id         = azurerm_lb.lbi.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}