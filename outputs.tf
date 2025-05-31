# outputs.tf
output "virtual_machine_names" {
  description = "Output VM names for all instances"
  value = merge(
    { for k, v in module.linux_vm : k => v.name }
  )
}

output "azurerm_public_ip" {
  value       = module.public_lb.azurerm_public_ip["frontend_configuration_1"].ip_address
  description = "Outputs each Public IP Address resource in it's entirety"
}