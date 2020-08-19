output "public_ip" {
  value = data.azurerm_public_ip.ip.ip_address
}