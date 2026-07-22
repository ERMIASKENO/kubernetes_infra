data "azurerm_subscription" "current" {}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-ecom"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "rg_diag" {
  name                       = "rg-diagnostics"
  target_resource_id         = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AllMetrics"
  }
}
