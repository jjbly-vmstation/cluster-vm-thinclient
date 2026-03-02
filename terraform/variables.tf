variable "vmws_url" {
  description = "VMware Workstation REST API URL"
  type        = string
  default     = "http://localhost:8697/api"
}

variable "vmws_user" {
  description = "VMware REST API User"
  type        = string
  sensitive   = true
  default     = "" # Allow environment variables to take precedence
}

variable "vmws_password" {
  description = "VMware REST API Password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "windows-11-enterprise"
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 12288
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
  default     = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"

}