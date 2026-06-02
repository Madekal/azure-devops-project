#variables for main main.tf


variable "vm_admin_password" {
  type = "string"
  sensitive = true
  description = "VM admin password"

}