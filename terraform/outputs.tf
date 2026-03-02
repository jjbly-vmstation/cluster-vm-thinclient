output "vm_name" {
  description = "Name of the Windows VM"
  value       = vmworkstation_virtual_machine.windows_vm.vm_name
}

output "vm_id" {
  description = "VMware Workstation VM ID"
  value       = vmworkstation_virtual_machine.windows_vm.id
}

output "vm_ip" {
  description = "IP Address (requires VMware Tools)"
  value       = vmworkstation_virtual_machine.windows_vm.ip_address
}