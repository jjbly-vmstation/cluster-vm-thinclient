variable "hyperv_host" {
  description = "IP address of the Hyper-V host (R430)"
  type        = string
  default     = "192.168.4.62"
}

variable "hyperv_user" {
  description = "Hyper-V admin user (domain\\user format)"
  type        = string
  default     = "VMSTATION\\ansible_svc"
}

variable "hyperv_password" {
  description = "Hyper-V admin password"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
}

variable "processors" {
  description = "Number of vCPUs"
  type        = number
  default     = 4
}

variable "memory_startup_mb" {
  description = "Startup RAM in MB"
  type        = number
  default     = 4096
}

variable "memory_max_mb" {
  description = "Maximum RAM in MB"
  type        = number
  default     = 16384
}
