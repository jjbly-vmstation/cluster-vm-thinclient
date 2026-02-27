variable "vmws_url" {
  description = "VMware Workstation REST API URL"
  type        = string
  default     = "http://localhost:8697/api"
}

variable "vmws_user" {
  description = "VMware REST API User"
  type        = string
  sensitive   = true
}

variable "vmws_password" {
  description = "VMware REST API Password"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "windows-11-enterprise"
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 4
}

variable "disk_size_gb" {
  description = "Main disk size in GB"
  type        = number
  default     = 100
}

variable "iso_path" {
  description = "Path to Windows 11 ISO"
  type        = string
}