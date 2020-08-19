provider "azurerm" {
  features {}
}

resource "null_resource" "shared_disk0" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk0 --size-gb 256 -l westcentralus --max-shares 2"
  }
}
resource "null_resource" "shared_disk1" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk1 --size-gb 256 -l westcentralus --max-shares 2"
  }
}
resource "null_resource" "shared_disk2" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk2 --size-gb 256 -l westcentralus --max-shares 2"
  }
}

data "azurerm_managed_disk" "existing0" {
  name                = "shared_disk0"
  resource_group_name = var.rg
  depends_on          = [ null_resource.shared_disk0, ]
}
data "azurerm_managed_disk" "existing1" {
  name                = "shared_disk1"
  resource_group_name = var.rg
  depends_on          = [ null_resource.shared_disk1, ]
}
data "azurerm_managed_disk" "existing2" {
  name                = "shared_disk2"
  resource_group_name = var.rg
  depends_on          = [ null_resource.shared_disk2, ]
}

resource "azurerm_proximity_placement_group" "node" {
  name                = var.region
  location            = var.region
  resource_group_name = var.rg
}

resource "azurerm_availability_set" "node" {
  name                = "node"
  location            = var.region
  resource_group_name = var.rg
  proximity_placement_group_id = azurerm_proximity_placement_group.node.id
  platform_fault_domain_count = "1"
  platform_update_domain_count = "1"
}

# Create network interfaces
resource "azurerm_network_interface" "node-0" {
    name                      = "node-0"
    location                  = var.region
    resource_group_name       = var.rg

    ip_configuration {
        name                          = "node-0-private"
        subnet_id                     = var.subnet
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.6"
        primary                       = "true"
    }
}
resource "azurerm_network_interface" "node-1" {
    name                      = "node-1"
    location                  = var.region
    resource_group_name       = var.rg

    ip_configuration {
        name                          = "node-1-private"
        subnet_id                     = var.subnet
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.7"
        primary                       = "true"
    }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "node-0" {
    name                  = "node-0"
    location              = var.region
    resource_group_name   = var.rg
    proximity_placement_group_id = azurerm_proximity_placement_group.node.id
    network_interface_ids = [azurerm_network_interface.node-0.id]
    size                  = "Standard_DS2_v2"

    os_disk {
        name              = "node-0"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb      = "100"
    }

    source_image_reference {
        publisher = var.publisher
        offer     = var.offer
        sku       = var.sku
        version   = var._version
    }

    computer_name  = "node-0"
    availability_set_id = azurerm_availability_set.node.id
    admin_username = "azureadmin"
#    custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }
}

resource "azurerm_managed_disk" "node-0a" {
  name                 = "${azurerm_linux_virtual_machine.node-0.name}-disk1a"
  location             = var.region
  resource_group_name  = var.rg
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}
resource "azurerm_virtual_machine_data_disk_attachment" "node-0a" {
  managed_disk_id    = azurerm_managed_disk.node-0a.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "node-0b" {
  name                 = "${azurerm_linux_virtual_machine.node-0.name}-disk1b"
  location             = var.region
  resource_group_name  = var.rg
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}
resource "azurerm_virtual_machine_data_disk_attachment" "node-0b" {
  managed_disk_id    = azurerm_managed_disk.node-0b.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "1"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk0_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing0.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "2"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk1_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing1.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "3"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk2_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing2.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "4"
  caching            = "None"
}

resource "azurerm_linux_virtual_machine" "node-1" {
    name                  = "node-1"
    location              = var.region
    resource_group_name   = var.rg
    proximity_placement_group_id = azurerm_proximity_placement_group.node.id
    network_interface_ids = [azurerm_network_interface.node-1.id]
    size                  = "Standard_DS2_v2"

    os_disk {
        name              = "node-1"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb      = "100"
    }

    source_image_reference {
        publisher = var.publisher
        offer     = var.offer
        sku       = var.sku
        version   = var._version
    }

    computer_name  = "node-1"
    availability_set_id = azurerm_availability_set.node.id
    admin_username = "azureadmin"
#    custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }
}

resource "azurerm_managed_disk" "node-1a" {
  name                 = "${azurerm_linux_virtual_machine.node-1.name}-disk1a"
  location             = var.region
  resource_group_name  = var.rg
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}
resource "azurerm_virtual_machine_data_disk_attachment" "node-1a" {
  managed_disk_id    = azurerm_managed_disk.node-1a.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "node-1b" {
  name                 = "${azurerm_linux_virtual_machine.node-1.name}-disk1b"
  location             = var.region
  resource_group_name  = var.rg
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}
resource "azurerm_virtual_machine_data_disk_attachment" "node-1b" {
  managed_disk_id    = azurerm_managed_disk.node-1b.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "1"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk0_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing0.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "2"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk1_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing1.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "3"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk2_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing2.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "4"
  caching            = "None"
}