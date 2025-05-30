variable "HCP_CLIENT_ID" {
  description = "HCP Client ID"
  type        = string
  sensitive   = true
}

variable "HCP_CLIENT_SECRET" {
  description = "HCP Client Secret"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}

variable "linux_vm_count" {
  description = "Number of Linux VMs to create"
  type        = number
  default     = 2
}

variable "linux_vm_sku_size" {
  description = "SKU size for Linux VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "priority" {
  description = "Priority for the VMs"
  type        = string
}

variable "spot_max_price" {
  description = "Max price for spot VMs"
  type        = number
}

variable "eviction_policy" {
  description = "Eviction policy for spot VMs"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
}