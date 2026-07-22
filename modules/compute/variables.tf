variable "resource_group_name" { type = string }
variable "location"           { type = string }
variable "subnet_id"          { type = string }
variable "identity_id"        { type = string }
variable "lb_backend_pool_id" { type = string }

variable "control_plane_vm_size" { type = string }
variable "worker_vm_size"        { type = string }
variable "worker_count"          { type = number }

variable "admin_username"       { type = string }
variable "admin_ssh_public_key" { type = string }

variable "kubeadm_join_command" { type = string }

variable "prefix" { type = string }
variable "tags"   { type = map(string) }
