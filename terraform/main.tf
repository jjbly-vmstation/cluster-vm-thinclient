terraform {
  required_version = ">= 1.5.0" [cite: 1]
  required_providers {
    vmware = {
      source  = "chap-at/vmware-desktop"
      version = "1.2.1"
    }
  }
}

# No provider block needed for local workstation execution
# It uses the 'vmrun' utility on the host

resource "vmware-desktop_virtual_machine" "windows_vm" {
  name     = var.vm_name [cite: 5]
  target_os = "windows11-64"
  
  # Resource Specs
  cpus      = var.vcpus [cite: 2, 5]
  memory    = var.memory_mb [cite: 5]
  firmware  = "efi" 

  # Storage
  gui = true
  
  network_adapter {
    type = "bridged" 
  }

  cdrom {
    path = var.iso_path [cite: 2, 5]
  }

  detach = false
}