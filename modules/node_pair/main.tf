provider "azurerm" {
  features {}
}

resource "null_resource" "shared_disk0" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk0 --size-gb 4 -l ${var.region} --sku UltraSSD_LRS --zone ${var.az} --disk-iops-read-write 120 --disk-mbps-read-write 10 --max-shares 2"
  }
}
resource "null_resource" "shared_disk1" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk1 --size-gb 4 -l ${var.region} --sku UltraSSD_LRS --zone ${var.az} --disk-iops-read-write 120 --disk-mbps-read-write 10 --max-shares 2"
  }
}
resource "null_resource" "shared_disk2" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk2 --size-gb 4 -l ${var.region} --sku UltraSSD_LRS --zone ${var.az} --disk-iops-read-write 120 --disk-mbps-read-write 10 --max-shares 2"
  }
}
resource "null_resource" "shared_disk3" {
  provisioner "local-exec" {
    command = "az disk create -g ${var.rg} -n shared_disk3 --size-gb 64 -l ${var.region} --sku UltraSSD_LRS --zone ${var.az} --disk-iops-read-write 240 --disk-mbps-read-write 50 --max-shares 2"
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
data "azurerm_managed_disk" "existing3" {
  name                = "shared_disk3"
  resource_group_name = var.rg
  depends_on          = [ null_resource.shared_disk3, ]
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
    zone                  = var.az
    network_interface_ids = [azurerm_network_interface.node-0.id]
    size                  = var.vm_size

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
    admin_username = "azureadmin"
#    custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }
    
    additional_capabilities {
      ultra_ssd_enabled = true
    }

    tags = {
    group = "node0"
    }
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk0_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing0.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "1"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk1_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing1.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "2"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk2_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing2.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "3"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk3_0" {
  managed_disk_id    = data.azurerm_managed_disk.existing3.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-0.id
  lun                = "4"
  caching            = "None"
}

resource "azurerm_linux_virtual_machine" "node-1" {
    name                  = "node-1"
    location              = var.region
    resource_group_name   = var.rg
    zone                  = var.az
    network_interface_ids = [azurerm_network_interface.node-1.id]
    size                  = var.vm_size

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
    admin_username = "azureadmin"
#    custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }

    additional_capabilities {
      ultra_ssd_enabled = true
    }

    tags = {
      group = "node1"
    }
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk0_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing0.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "1"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk1_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing1.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "2"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk2_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing2.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "3"
  caching            = "None"
}
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disk3_1" {
  managed_disk_id    = data.azurerm_managed_disk.existing3.id
  virtual_machine_id = azurerm_linux_virtual_machine.node-1.id
  lun                = "4"
  caching            = "None"
}