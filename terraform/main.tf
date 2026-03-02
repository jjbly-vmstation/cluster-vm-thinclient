terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "2.0.1"
    }
  }
}

provider "vmworkstation" {
  # Remove the url, user, and password lines here.
  # The provider will now automatically grab VMWS_ENDPOINT, 
  # VMWS_USERNAME, and VMWS_PASSWORD from your Ansible environment.
  https = false
}

resource "vmworkstation_vm" "windows_vm" {
  vm_name = var.vm_name
  vm_path = "[standard]/${var.vm_name}"

  guest_os_type = "windows11-64"
  mem_size      = var.memory_mb
  num_cpus      = var.vcpus
  firmware      = "efi"

  disks = [
    {
      size = var.disk_size_gb
    }
  ]

  cdrom = {
    iso_path = var.iso_path
  }

  network_interfaces = [
    {
      network_name = "Bridged"
    }
  ]
  power_on = true
}