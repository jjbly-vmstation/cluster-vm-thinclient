output "vm_name" {
  description = "Name of the Windows VM"
  value       = vmworkstation_virtual_machine.windows_vm.denomination
}

output "vm_id" {
  description = "VMware Workstation VM ID"
  value       = vmworkstation_virtual_machine.windows_vm.id
}