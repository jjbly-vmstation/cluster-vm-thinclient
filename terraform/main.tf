terraform {
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "2.0.1"
    }
  }
}

provider "vmworkstation" {
  endpoint = "http://127.0.0.1:8697/api"
  username = "vmadmin"
  password = "VMwarePassword1!"
  debug    = true
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  denomination = "windows-thinclient"
  description  = "Enterprise - Massgrave Activated"
  processors   = 4
  memory       = 12288
  sourceid     = var.sourceid # Passed from Ansible
  path         = "/home/vmadmin/vmware/windows-thinclient/windows-thinclient.vmx"

  lifecycle {
    # If the VM is manually deleted, Terraform recreates it on next run
    replace_triggered_by = [
      null_resource.force_rebuild_on_corruption
    ]
  }


}