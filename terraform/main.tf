terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user     = var.hyperv_user
  password = var.hyperv_password
  host     = var.hyperv_host
  port     = 5985
  https    = false
  insecure = true
  use_ntlm = true
}

# Copy the golden VHDX from NFS to the F: RAID10 drive for this VM
resource "hyperv_vhd" "vm_disk" {
  path   = "F:\\Hyper-V\\Virtual Hard Disks\\${var.vm_name}\\${var.vm_name}.vhdx"
  source = "Z:\\iso\\win11e\\win11-base.vhdx"
}

resource "hyperv_machine_instance" "vm" {
  name            = var.vm_name
  generation      = 2
  processor_count = var.processors

  # Dynamic memory
  static_memory        = false
  memory_startup_bytes = var.memory_startup_mb * 1024 * 1024
  memory_minimum_bytes = 2147483648        # 2GB floor
  memory_maximum_bytes = var.memory_max_mb * 1024 * 1024
  memory_buffer        = 20

  # Secure boot for Gen 2 Win11
  secure_boot         = true
  secure_boot_template = "MicrosoftWindows"

  # Use the external switch so the VM gets a real LAN IP
  network_adaptors {
    name        = "LAN"
    switch_name = "Broadcom NetXtreme Gigabit Ethernet #2 - Virtual Switch"
  }

  # Point at the VHDX we copied to F:
  hard_disk_drives {
    controller_type     = "Scsi"
    controller_number   = 0
    controller_location = 0
    path                = hyperv_vhd.vm_disk.path
  }

  # Boot from disk
  dvd_drives {}

  depends_on = [hyperv_vhd.vm_disk]
}
