resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  purge_protection_enabled    = true
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  enabled_for_template_deployment = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.admin_object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"
    ]
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.identity_principal_id

    secret_permissions = [
      "Get", "List"
    ]
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "ecommerce-db-password"
  value        = var.example_db_password
  key_vault_id = azurerm_key_vault.kv.id
  tags         = var.tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "-pe-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "kv-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = var.tags
}
