terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  resource_group_name           = module.resource_group.name
  location                      = var.location
  vnet_cidr                     = var.vnet_cidr
  k8s_subnet_cidr               = var.k8s_subnet_cidr
  bastion_subnet_cidr           = var.bastion_subnet_cidr
  private_endpoints_subnet_cidr = var.private_endpoints_subnet_cidr
  admin_allowed_cidr            = var.admin_allowed_cidr
  prefix                        = var.prefix
  tags                          = var.tags
}

module "identity" {
  source = "./modules/identity"

  resource_group_name = module.resource_group.name
  location            = var.location
  prefix              = var.prefix
  tags                = var.tags
}

module "load_balancer" {
  source = "./modules/load_balancer"

  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.network.k8s_subnet_id
  prefix              = var.prefix
  tags                = var.tags
}

module "compute" {
  source = "./modules/compute"

  resource_group_name   = module.resource_group.name
  location              = var.location
  subnet_id             = module.network.k8s_subnet_id
  identity_id           = module.identity.id
  lb_backend_pool_id    = module.load_balancer.backend_pool_id

  control_plane_vm_size = var.control_plane_vm_size
  worker_vm_size        = var.worker_vm_size
  worker_count          = var.worker_count

  admin_username        = var.admin_username
  admin_ssh_public_key  = var.admin_ssh_public_key

  kubeadm_join_command  = var.kubeadm_join_command

  prefix = var.prefix
  tags   = var.tags
}

module "acr" {
  source = "./modules/acr"

  resource_group_name        = module.resource_group.name
  location                   = var.location
  acr_name                   = var.acr_name
  identity_principal_id      = module.identity.principal_id
  private_endpoint_subnet_id = module.network.private_endpoints_subnet_id
  prefix                     = var.prefix
  tags                       = var.tags
}

module "key_vault" {
  source = "./modules/key_vault"

  resource_group_name        = module.resource_group.name
  location                   = var.location
  key_vault_name             = var.key_vault_name
  tenant_id                  = var.tenant_id
  admin_object_id            = var.admin_object_id
  identity_principal_id      = module.identity.principal_id
  private_endpoint_subnet_id = module.network.private_endpoints_subnet_id
  example_db_password        = var.example_db_password
  prefix                     = var.prefix
  tags                       = var.tags
}

module "diagnostics" {
  source = "./modules/diagnostics"

  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}
