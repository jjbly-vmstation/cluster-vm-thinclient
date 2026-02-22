output "vm_name" {
  description = "Name of the Windows VM"
  value       = libvirt_domain.windows.name
}

output "vm_id" {
  description = "Libvirt domain ID"
  value       = libvirt_domain.windows.id
}

output "os_disk_path" {
  description = "Path to OS disk qcow2"
  value       = libvirt_volume.windows_os.id
}

output "data_disk_path" {
  description = "Path to data disk qcow2"
  value       = libvirt_volume.windows_data.id
}

output "mac_address" {
  description = "VM MAC address (pinned for activation)"
  value       = var.mac_address
}
