
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name = azurerm_resource_group.arg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                 = var.storage_container_name
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_storage_blob" "blob" {
  name                   = "tb-file.sh"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "command.sh"
}