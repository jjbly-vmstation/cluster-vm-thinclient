output "vm_name" {
  description = "Name of the deployed VM"
  value       = hyperv_machine_instance.vm.name
}

output "vm_disk_path" {
  description = "Path to the VM's VHDX on the F: RAID10 drive"
  value       = hyperv_vhd.vm_disk.path
}
