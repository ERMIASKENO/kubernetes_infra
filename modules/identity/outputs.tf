output "id" {
  value = azurerm_user_assigned_identity.vm_identity.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.vm_identity.principal_id
}
