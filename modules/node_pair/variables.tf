variable "rg" {
  description = "The Resource Group name for all resources in this module"
}

variable "region" {
  description = "The Azure location where all resources in this example should be created"
}

variable "vm_size" {
  description = "The VM size/type"
}

variable "az" {
  description = "The Availibility Zone of the resource"
}

variable "subnet" {
  description = "The subnet for all resources in this module"
}

################################
# publisher = "SUSE"
# offer     = "sles-sap-12-sp5"
# sku       = "gen2"
# _version   = "latest"
################################
# publisher = "SUSE"
# offer     = "SLES-SAP"
# sku       = "12-sp4-gen2"
# _version   = "latest"
################################
variable "publisher" {
  description = "Publisher of the image used to create VM"
}
variable "offer" {
  description = "Offer of the image used to create VM"
}
variable "sku" {
  description = "SKU of the image used to create VM"
}
variable "_version" {
  description = "Version of the image used to create VM, underscore added to avoid Terraform error"
}