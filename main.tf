
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

# Create a network security group with an SSH rule
resource "azurerm_network_security_group" "ansg" {
  name                = "app_nsg"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  # Define rules including SSH
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Add more security rules as needed
}


resource "azurerm_network_interface" "nic" {
  name                = "tvnet_nic"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.sub.id

    private_ip_address_allocation = "Static"
    private_ip_address           = "10.0.0.10"  # Replace with a valid private IP address
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
  resource_group_name  = azurerm_resource_group.arg.name
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

resource "azurerm_route_table" "custom_route_table" {
  name                = "custom-route-table"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_route" "route1" {
  name                = "route1"
  resource_group_name = azurerm_resource_group.arg.name
  route_table_name    = azurerm_route_table.custom_route_table.name
  address_prefix      = "0.0.0.0/0"  # This is a default route, you can modify it as needed
  next_hop_type       = "VirtualAppliance"  # Change this based on your setup
  next_hop_in_ip_address = "10.0.5.0"   # Specify the appropriate next hop IP address for the virtual appliance
}