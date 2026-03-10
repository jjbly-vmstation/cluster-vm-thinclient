terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user            = "Administrator@VMSTATION.LOCAL"
  # Since you have a Kerberos ticket, you can often omit the password 
  # depending on your shell's environment
  https           = false
  insecure        = true
  use_ntlm        = false
  host            = "192.168.4.62"
  port            = 5985
}

resource "hyperv_machine_instance" "productivity_vm" {
  name                   = "productivity-vm"
  generation             = 2
  processor_count        = 4
  
  # Set to false to allow memory to grow/shrink
  static_memory          = false 
  
  # Minimum RAM (e.g., 2GB)
  memory_startup_bytes   = 2147483648 
  
  # Maximum RAM (16GB)
  memory_maximum_bytes   = 17179869184 
  
  # Memory Buffer (percentage to keep available)
  memory_buffer          = 20

  network_adaptors {
    name        = "wan"
    switch_name = "Internal-NAT-Switch"
  }

  hard_disk_drives {
    path = "C:\\Hyper-V\\Virtual Hard Disks\\productivity-vm.vhdx"
  }
}