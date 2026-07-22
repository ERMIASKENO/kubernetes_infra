variable "resource_group_name"        { type = string }
variable "location"                  { type = string }
variable "key_vault_name"            { type = string }
variable "tenant_id"                 { type = string }
variable "admin_object_id"           { type = string }
variable "identity_principal_id"     { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "example_db_password" {
  type      = string
  sensitive = true
}
variable "prefix" { type = string }
variable "tags"   { type = map(string) }
