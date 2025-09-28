# tests/main.tftest.hcl

# Acknowledge Framework Limitations
# These tests are designed to verify the Azure resource configuration as defined in the Terraform code.
# They can validate aspects like resource counts, SKU types, and associations between resources.
# However, they cannot verify the application-level status, such as making an HTTP request to confirm
# that the Nginx web server is actively responding on the provisioned VMs.

variables {
  location          = "eastus"
  priority          = "Regular"
  spot_max_price    = -1
  eviction_policy   = "Deallocate"
  linux_vm_sku_size = "Standard_B2s" # Default value from variables.tf
  # The admin_password variable is marked as sensitive and should be provided
  # through a .tfvars file or as an environment variable, not hardcoded.
  admin_password = "PasswordIsNotHardcoded123!"
}

# Define the provider block for the tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# --------------------------------------------------
# Data sources for Apply-based Tests
# --------------------------------------------------

# These data sources are defined at the top level and are used by the run blocks below.
# This avoids the error of defining data sources inside run blocks.

data "azurerm_resource_group" "rg" {
  name = module.resource_group.name
}

data "azurerm_lb" "lb" {
  name                = module.public_lb.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_lb_backend_address_pool" "pool" {
  name            = "primaryPool"
  loadbalancer_id = data.azurerm_lb.lb.id
}

data "azurerm_lb_probe" "probe" {
  name            = "myHealthProbe"
  loadbalancer_id = data.azurerm_lb.lb.id
}

# Fetch the network interfaces associated with the VMs created in the module.
data "azurerm_network_interface" "nics" {
  for_each            = module.linux_vm
  name                = each.value.network_interfaces.network_interface_1.name
  resource_group_name = data.azurerm_resource_group.rg.name
}


# --------------------------------------------------
# Plan-based Tests (Unit Tests)
# --------------------------------------------------

# Helper to find resources of a specific type from the plan, regardless of module depth.
locals {
  planned_resources = {
    for r in terraform.planned_values.resources : r.address => r
  }
  vms = {
    for addr, res in local.planned_resources : addr => res if res.type == "azurerm_linux_virtual_machine"
  }
  nics = {
    for addr, res in local.planned_resources : addr => res if res.type == "azurerm_network_interface"
  }
  lbs = {
    for addr, res in local.planned_resources : addr => res if res.type == "azurerm_lb"
  }
  rgs = {
    for addr, res in local.planned_resources : addr => res if res.type == "azurerm_resource_group"
  }
}

run "plan_assert_resource_counts" {
  command = plan

  assert {
    condition     = length(local.vms) == 2
    error_message = "Plan should include exactly two virtual machines."
  }

  assert {
    condition     = length(local.nics) == 2
    error_message = "Plan should include exactly two network interfaces."
  }
}

run "plan_assert_load_balancer_sku" {
  command = plan

  assert {
    condition     = one(local.lbs).values.sku == "Standard"
    error_message = "Load Balancer SKU should be 'Standard'."
  }
}

run "plan_assert_vm_size" {
  command = plan

  assert {
    condition = alltrue([
      for vm in local.vms : vm.values.size == var.linux_vm_sku_size
    ])
    error_message = "All VMs should be configured with the size specified in the 'linux_vm_sku_size' variable."
  }
}

run "plan_assert_resource_locations" {
  command = plan

  assert {
    condition     = one(local.rgs).values.location == var.location
    error_message = "Resource group should be in the location specified by the 'location' variable."
  }

  assert {
    condition     = one(local.lbs).values.location == var.location
    error_message = "Load balancer should be in the location specified by the 'location' variable."
  }

  assert {
    condition = alltrue([
      for vm in local.vms : vm.values.location == var.location
    ])
    error_message = "All VMs should be in the location specified by the 'location' variable."
  }
}


# --------------------------------------------------
# Apply-based Tests (Integration Tests)
# --------------------------------------------------

# Test Case: Validate Load Balancer Public IP
# This test verifies that the load balancer's public IP address is successfully allocated.
run "apply_validate_lb_public_ip" {
  command = apply

  assert {
    condition     = output.azurerm_public_ip != null && output.azurerm_public_ip != ""
    error_message = "Load Balancer public IP output 'azurerm_public_ip' should not be null or empty."
  }
}

# Test Case: Validate Network Interface Backend Pool Association
# This test ensures that the network interfaces of the virtual machines are correctly
# associated with the backend address pool of the 'module.public_lb' load balancer.
run "apply_validate_nic_backend_pool_association" {
  command = apply

  assert {
    condition = alltrue([
      for nic in data.azurerm_network_interface.nics : contains(nic.ip_configuration[0].load_balancer_backend_address_pool_ids, data.azurerm_lb_backend_address_pool.pool.id)
    ])
    error_message = "All network interfaces should be associated with the load balancer's backend address pool."
  }
}

# Test Case: Validate Health Probe Configuration
# This test checks that the load balancer's health probe is configured to use the correct port (Port 80).
run "apply_validate_health_probe_port" {
  command = apply

  assert {
    condition     = data.azurerm_lb_probe.probe.port == 80
    error_message = "Health probe should be configured for Port 80."
  }
}