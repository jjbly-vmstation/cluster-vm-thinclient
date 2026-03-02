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
  # These are the specific names the provider v2.0.1 requires
  endpoint = var.vmws_url
  username = var.vmws_user
  password = var.vmws_password
  https    = false
}

resource "vmworkstation_virtual_machine" "windows_vm" {
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