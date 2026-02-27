variable "libvirt_uri" {
  description = "Libvirt connection URI (e.g., qemu:///system or qemu+ssh://...)"
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
  description = "Full path to Windows 11 installation ISO"
  type        = string
}

variable "virtio_iso_path" {
  description = "Full path to virtio-win ISO (drivers for virtio devices)"
  type        = string
  default     = "/home/vmadmin/iso/virtio-win.iso"   # matches your listing
}

variable "network_name" {
  description = "Libvirt network name (default NAT) or bridge (e.g., br0)"
  type        = string
  default     = "default"
}

variable "mac_address" {
  description = "Pinned MAC address for stable Windows activation"
  type        = string
  default     = "52:54:00:00:f0:0d"
}

variable "firmware_path" {
  description = "Path to OVMF Secure Boot firmware code"
  type        = string
  # Using the system path (you can override if you copied the file elsewhere)
  default     = "/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd"
}

variable "nvram_template" {
  description = "Path to OVMF variables template (with Secure Boot keys)"
  type        = string
  # System provides OVMF.qemuvars.fd as a suitable template
  default     = "/usr/share/edk2/ovmf/OVMF.qemuvars.fd"
}

variable "nvram_file" {
  description = "Path where the VM‑specific NVRAM copy will be stored"
  type        = string
  default     = "/home/vmadmin/disks/windows-vars.fd"
}