output "vm_name" {
  description = "Name of the deployed VM"
  value       = hyperv_machine_instance.vm.name
}

output "vm_disk_path" {
  description = "Path to the VM's VHDX on the F: RAID10 drive"
  value       = "F:\\Hyper-V\\Virtual Hard Disks\\${var.vm_name}\\${var.vm_name}.vhdx"
}
