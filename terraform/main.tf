terraform {
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "2.0.1"
    }
  }
}

# Credentials are now passed via variables
provider "vmworkstation" {
  endpoint = var.vmws_url
  username = var.vmws_user
  password = var.vmws_pass
  debug    = true
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  denomination = "windows-thinclient"
  description  = "Enterprise - Massgrave Activated"
  processors   = 4
  memory       = 12288
  sourceid     = var.sourceid
  path         = "/home/vmadmin/vmware/windows-thinclient/windows-thinclient.vmx"

}