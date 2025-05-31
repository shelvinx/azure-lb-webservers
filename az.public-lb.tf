# az.public-lb.tf
module "public_lb" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.4.0"

  name                = module.naming.lb.name
  location            = var.location
  resource_group_name = module.resource_group.name

  # Frontend IP Configuration
  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                            = "myFrontend"
      create_public_ip_address        = true
      public_ip_address_resource_name = module.naming.public_ip.name_unique
      # zones = ["1", "2", "3"] # Zone-redundant
      # zones = ["None"] # Non-zonal
    }
  }

  # Backend Address Pool(s)
  backend_address_pools = {
    pool1 = {
      name = "primaryPool"
    }
  }

  backend_address_pool_addresses = {
    for vm_key, vm_config in local.linux_vm_instances : vm_key => {
      name                             = "${module.naming.network_interface.name}-${vm_key}-ipconfig"
      backend_address_pool_object_name = "pool1"
      ip_address                       = module.linux_vm[vm_key].virtual_machine_azurerm.private_ip_address
      virtual_network_resource_id      = module.vnet_test.resource_id
    }
  }

  # Health Probe(s)
  lb_probes = {
    tcp1 = {
      name     = "myHealthProbe"
      protocol = "Tcp"
    }
  }

  # Load Balaner rule(s)
  lb_rules = {
    http1 = {
      name                           = "myHTTPRule"
      frontend_ip_configuration_name = "myFrontend"

      backend_address_pool_object_names = ["pool1"]
      protocol                          = "Tcp"
      frontend_port                     = 80
      backend_port                      = 80

      probe_object_name = "tcp1"

      idle_timeout_in_minutes = 15
      enable_tcp_reset        = true

      disable_outbound_snat = true
    }
  }

  lb_outbound_rules = {
    lb_nat_outbound_rule = {
      name                             = "lb_nat_outbound_rule"
      frontend_ip_configurations = [
        {
          name = "myFrontend"
        }
      ]

      backend_address_pool_object_name = "pool1"
      protocol                         = "All"
      number_of_allocated_outbound_ports = 10000
    }
  }
  tags = var.tags
}
