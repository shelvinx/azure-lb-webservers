# terraform.tfvars
# Number of VMs
linux_vm_count = 2

location = "uksouth"

# Tags
tags = {
  created-by = "terraform"
  project    = "az-lb-webservers"
}

# Spot VMs
priority        = "Spot"
spot_max_price  = 0.07
eviction_policy = "Deallocate"

# VMs
linux_vm_sku_size = "Standard_F2s_v2"