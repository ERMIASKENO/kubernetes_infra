resource "azurerm_user_assigned_identity" "vm_identity" {
  name                = "-vm-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
