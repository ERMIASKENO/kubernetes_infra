output "k8s_subnet_id" {
  value = azurerm_subnet.k8s.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}
