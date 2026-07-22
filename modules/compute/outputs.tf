output "control_plane_private_ip" {
  value = azurerm_network_interface.cp_nic.ip_configuration[0].private_ip_address
}
