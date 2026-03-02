terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "1.0.4"
    }
  }
}

provider "vmworkstation" {
  user     = var.vmws_user
  password = var.vmws_password
  url      = var.vmws_url
  https    = false
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  name          = var.vm_name
  os            = "windows11-64"
  memory        = var.memory_mb
  cpus          = var.vcpus
  
  # This version uses simpler paths
  path          = "/home/vmadmin/vmstation-org/cluster-vm-thinclient/terraform/${var.vm_name}.vmx"

  # Networking
  network_adapter {
    type = "bridged"
  }

  # ISO for Installation
  cdrom {
    path = var.iso_path
  }
}