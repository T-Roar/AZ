
resource "azurerm_virtual_network" "tvnet" {
  name                = var.network
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_subnet" "sub" {
  name                 = "tvnet_sub"
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.tvnet.name
  address_prefixes     = var.address
}

resource "azurerm_network_security_group" "ansg" {
  name                = "tvnet_ansg"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "tvnet_nic"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.sub.id

    private_ip_address_allocation = "Dynamic"  # or "Static"
  }
}


resource "azurerm_public_ip" "pub" {
  name                = "testpip"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.tvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_firewall" "azfirewall" {
  name                = "azfire"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.pub.id
  }
}