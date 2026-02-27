variable "libvirt_uri" {
  description = "Libvirt connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "pool_name" {
  description = "Storage pool name"
  type        = string
  default     = "default"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "windows-thinclient"
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
  description = "Path to Windows 11 ISO"
  type        = string
}

variable "virtio_iso_path" {
  description = "Path to virtio-win ISO"
  type        = string
  default     = "/home/vmadmin/iso/virtio-win.iso"
}

variable "network_name" {
  description = "Libvirt network name"
  type        = string
  default     = "default"
}

variable "mac_address" {
  description = "Pinned MAC address"
  type        = string
  default     = "52:54:00:00:f0:0d"
}

variable "firmware_path" {
  description = "Path to OVMF firmware with Secure Boot"
  type        = string
  default     = "/home/vmadmin/disks/firmware/OVMF_CODE.secboot.fd"
}

variable "nvram_template" {
  description = "Path to OVMF vars template"
  type        = string
  default     = "/home/vmadmin/disks/firmware/OVMF_VARS.fd"
}

variable "nvram_file" {
  description = "Path to VM‑specific NVRAM file"
  type        = string
  default     = "/home/vmadmin/disks/windows-vars.fd"
}