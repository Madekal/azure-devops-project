variable "vm_admin_password" {
  type        = string
  description = "Admin password for VMs"
  sensitive   = true
}

variable "resource_group_name" {
  type        = string
  description = "Name from main resource group"
}

variable "location" {
  type        = string
  description = "Location from main resource group"
}

variable "private_subnet_id"{
    type        = string
    description = "ID from private subnet"
}

variable "backend_pool_id" {
  type        = "Backend ID pool from Load Balancer"
}
