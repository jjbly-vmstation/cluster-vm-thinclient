variable "libvirt_uri" {
  description = "Libvirt connection URI (qemu+ssh for remote)"
  type        = string
  default     = "qemu:///system"
}

variable "pool_name" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "windows-thinclient"
}

variable "memory_mb" {
  description = "VM memory in MB"
  type        = number
  default     = 4096
}

variable "vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 64
}

variable "data_disk_size_gb" {
  description = "Data disk size in GB"
  type        = number
  default     = 100
}

variable "iso_path" {
  description = "Path to Windows install ISO (e.g. /home/vmadmin/iso/Win11.iso)"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Libvirt network name (default NAT) or bridge (e.g. br0)"
  type        = string
  default     = "default"
}

variable "mac_address" {
  description = "Pinned MAC address for stable Windows activation"
  type        = string
  default     = "52:54:00:a1:b2:c3"  # Replace with desired MAC
}

variable "firmware_path" {
  description = "Path to OVMF Secure Boot firmware code"
  type        = string
  default     = "/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd"
}

variable "nvram_template" {
  description = "Path to OVMF variables template"
  type        = string
  default     = "/usr/share/edk2/ovmf/OVMF_VARS.4m.fd"
}