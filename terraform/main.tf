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
  endpoint = var.vmws_url
  username = var.vmws_user
  password = var.vmws_password
  https    = false
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  # These are the NEW required fields for v2.0.1
  path         = "/home/vmadmin/vmstation-org/cluster-vm-thinclient/terraform/${var.vm_name}/${var.vm_name}.vmx"
  processors   = var.vcpus
  memory       = var.memory_mb
  sourceid     = "" # Leaving this blank for a fresh install from ISO
  description  = "Windows 11 Thin Client for Dad"
  denomination = var.vm_name
}