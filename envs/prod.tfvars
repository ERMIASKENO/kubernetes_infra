resource_group_name = "rg-ecommerce-prod"
location            = "westeurope"

prefix = "ecom-prod"

vnet_cidr                 = "10.0.0.0/16"
k8s_subnet_cidr           = "10.0.1.0/24"
bastion_subnet_cidr       = "10.0.10.0/27"
private_endpoints_subnet_cidr = "10.0.20.0/27"
admin_allowed_cidr        = "YOUR_IP/32"

admin_username       = "ermias"
admin_ssh_public_key = file("~/.ssh/id_rsa.pub")

control_plane_vm_size = "Standard_D4s_v5"
worker_vm_size        = "Standard_D4s_v5"
worker_count          = 2

acr_name        = "ecomacrprod123"
key_vault_name  = "kv-ecom-prod-123"
tenant_id       = "00000000-0000-0000-0000-000000000000"
admin_object_id = "11111111-1111-1111-1111-111111111111"

example_db_password   = "CHANGE_ME"
kubeadm_join_command  = "kubeadm join 10.0.1.4:6443 --token xxx --discovery-token-ca-cert-hash sha256:yyy"

tags = {
  environment = "prod"
  owner       = "ecommerce-team"
  costcenter  = "IT-001"
}
