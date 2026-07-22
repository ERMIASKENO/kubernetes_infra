output "lb_public_ip" {
  value = module.load_balancer.public_ip
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "key_vault_uri" {
  value = module.key_vault.uri
}

output "control_plane_private_ip" {
  value = module.compute.control_plane_private_ip
}
