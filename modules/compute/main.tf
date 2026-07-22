resource "azurerm_network_interface" "cp_nic" {
  name                = "-nic-cp"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.lb_backend_pool_id
  }

  tags = var.tags
}

resource "azurerm_network_interface" "worker_nic" {
  count               = var.worker_count
  name                = "-nic-worker-"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "control_plane" {
  name                = "-cp-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.control_plane_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.cp_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "-cp-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  custom_data = base64encode(
    file("/cloud_init/control-plane.yaml")
  )

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "worker" {
  count               = var.worker_count
  name                = "-worker-vm-"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.worker_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.worker_nic[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "-worker-osdisk-"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  custom_data = base64encode(
    templatefile("/cloud_init/worker.tpl", {
      join_command = var.kubeadm_join_command
    })
  )

  tags = var.tags
}
