variable "resource_group_name"        { type = string }
variable "location"                  { type = string }
variable "acr_name"                  { type = string }
variable "identity_principal_id"     { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "prefix"                    { type = string }
variable "tags"                      { type = map(string) }
