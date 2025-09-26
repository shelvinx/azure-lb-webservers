# Associate NAT rules with VM network interfaces
resource "azurerm_network_interface_nat_rule_association" "ssh" {
  for_each = {
    for k, v in { "lnx1" = "ssh-lnx1", "lnx2" = "ssh-lnx2" } : k => v
    if contains(keys(local.linux_vm_instances), k)
  }

  network_interface_id  = module.linux_vm[each.key].network_interfaces["network_interface_1"].id
  ip_configuration_name = "ipconfig-${each.key}"
  nat_rule_id           = module.public_lb.azurerm_lb_nat_rule[each.value].id
}