variable "resource_group_name" { type = string }
variable "location"           { type = string }

variable "prefix" {
  type    = string
  default = "ecom"
}

variable "vnet_cidr"                 { type = string }
variable "k8s_subnet_cidr"           { type = string }
variable "bastion_subnet_cidr"       { type = string }
variable "private_endpoints_subnet_cidr" { type = string }
variable "admin_allowed_cidr"        { type = string }

variable "admin_username"       { type = string }
variable "admin_ssh_public_key" { type = string }

variable "control_plane_vm_size" { type = string }
variable "worker_vm_size"        { type = string }
variable "worker_count"          { type = number }

variable "acr_name"        { type = string }
variable "key_vault_name"  { type = string }
variable "tenant_id"       { type = string }
variable "admin_object_id" { type = string }

variable "example_db_password" {
  type      = string
  sensitive = true
}

variable "kubeadm_join_command" {
  type        = string
  description = "Full kubeadm join command for worker nodes."
  default     = ""
}

variable "tags" {
  type = map(string)
}
