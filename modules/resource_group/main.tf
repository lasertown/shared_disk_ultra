provider "azurerm" {
  features {}
}

resource "random_id" "name" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}_${random_id.name.hex}"
  location = "westus2"
}
