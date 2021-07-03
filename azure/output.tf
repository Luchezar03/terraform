output "vm1_name" {
  value     = azurerm_windows_virtual_machine.vm1.name
  sensitive = true
}
