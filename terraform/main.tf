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
  debug    = true
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  denomination = var.vm_name
  path         = var.dest_path
  sourceid     = var.sourceid 
  processors   = var.processors
  memory       = var.memory
}