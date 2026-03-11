terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user        = var.hyperv_user
  password    = var.hyperv_password
  host        = "192.168.4.62"
  port        = 5985
  https       = false
  insecure    = true
  use_ntlm    = true
  script_path = "C:/Temp/terraform_%RAND%.cmd"
  timeout     = "60s"
}

resource "hyperv_machine_instance" "vm" {
  name            = var.vm_name
  generation      = 2
  processor_count = var.processors
  state           = "Running"

  dynamic_memory       = true
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
