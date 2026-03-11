terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user        = "VMSTATION\\ansible_svc"
  password    = var.hyperv_password
  host        = "192.168.4.62"
  port        = 5985
  https       = false
  insecure    = true
  use_ntlm    = true
  script_path = "C:/Temp/terraform_%RAND%.cmd"
  timeout     = "60s"
}

# Copy the golden VHDX from NFS to the F: RAID10 drive for this VM
resource "hyperv_vhd" "vm_disk" {
  path   = "F:\\Hyper-V\\Virtual Hard Disks\\${var.vm_name}\\${var.vm_name}.vhdx"
  source = "Z:\\iso\\win11e\\win11-base.vhdx"
}

# Remove the hyperv_vhd resource entirely - Ansible handles the copy
# Just create the VM pointing at the pre-copied VHDX

resource "hyperv_machine_instance" "vm" {
  name            = var.vm_name
  generation      = 2
  processor_count = var.processors
  state           = "Running"

  static_memory        = false
  memory_startup_bytes = var.memory_startup_mb * 1024 * 1024
  memory_minimum_bytes = 2147483648
  memory_maximum_bytes = var.memory_max_mb * 1024 * 1024

  vm_firmware {
    enable_secure_boot   = "On"
    secure_boot_template = "MicrosoftWindows"
  }

  network_adaptors {
    name        = "LAN"
    switch_name = "Broadcom NetXtreme Gigabit Ethernet #2 - Virtual Switch"
  }

  hard_disk_drives {
    controller_type     = "Scsi"
    controller_number   = 0
    controller_location = 0
    path                = "F:\\Hyper-V\\Virtual Hard Disks\\${var.vm_name}\\${var.vm_name}.vhdx"
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
  }
}
