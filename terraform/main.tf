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
  debug    = true  # <--- THIS IS THE MISSING PARAMETER
}

resource "vmworkstation_virtual_machine" "windows_vm" {
  # Standard 2.0.1 schema
  denomination = var.vm_name
  description  = "Windows 11 Enterprise for Dad"
  processors   = var.vcpus
  memory       = var.memory_mb
  
  # Ensure this path exists on the RHEL node
  path         = "/home/vmadmin/vmstation-org/cluster-vm-thinclient/terraform/${var.vm_name}.vmx"
  
  # Set sourceid to empty string for a new VM from ISO
  sourceid     = ""
}