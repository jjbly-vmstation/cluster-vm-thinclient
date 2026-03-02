variable "vmws_url" { default = "http://127.0.0.1:8697/api" }
variable "vmws_user" { default = "vmadmin" }
variable "vmws_pass" { type = string }
variable "sourceid" { type = string }


variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "windows-thinclient"
}


variable "sourceid" {
  description = "Path to the Packer-generated VMX template"
  type        = string
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

variable "data_disk_size_gb" {
  type    = number
  default = 100
}

variable "mac_address" {
  type    = string
  default = "52:54:00:00:f0:0d"
}

variable "iso_path" {
  description = "Path to Windows 11 ISO"
  type        = string
  default     = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"

}