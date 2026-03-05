terraform {
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
  password = var.vmws_pass
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  denomination = var.vm_name
  description  = var.vm_description
  processors   = var.processors
  memory       = var.memory
  sourceid     = var.sourceid
  path         = var.dest_path
}