terraform {
  required_version = ">= 1.5.0"
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
  name     = var.vm_name
  target_os = "windows11-64"
  
  # Resource Specs
  cpus      = var.vcpus
  memory    = var.memory_mb
  firmware  = "efi" 

  # Storage
  gui = true
  
  network_adapter {
    type = "bridged" 
  }

  cdrom {
    path = var.iso_path
  }

  detach = false
}