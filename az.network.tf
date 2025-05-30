module "vnet_test" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.1.0.0/16"]

  subnets = {
    vm_subnet_1 = {
      name             = "${module.naming.subnet.name}"
      address_prefixes = ["10.1.1.0/24"]
      network_security_group = {
        id = "${module.nsg_test.resource_id}"
      }
    }
  }

  tags = var.tags
}

module "nsg_test" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = module.naming.network_security_group.name
  location            = var.location
  resource_group_name = module.resource_group.name

  security_rules = local.nsg_rules
}