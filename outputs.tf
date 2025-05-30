# outputs.tf
output "public_ip_addresses" {
  description = "Output public IP addresses for all VMs"
  value = merge(
    { for k, v in module.pip_linux : k => v.public_ip_address }
  )
}

output "virtual_machine_names" {
  description = "Output VM names for all instances"
  value = merge(
    { for k, v in module.linux_vm : k => v.name }
  )
}

output "vm_fqdns" {
  description = "FQDN URLs for VMs (https://<domain_name_label>.cloudapp.azure.com)"
  value = merge(
    { for k, v in module.pip_linux : k => "${module.naming.virtual_machine.name}-${k}.${var.location}.cloudapp.azure.com" }
  )
}

output "azurerm_public_ip" {
  value       = module.public_lb.azurerm_public_ip["frontend_configuration_1"].ip_address
  description = "Outputs each Public IP Address resource in it's entirety"
}