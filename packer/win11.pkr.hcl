packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "vm_password" {
  type      = string
  sensitive = true
}

source "vmware-iso" "windows_11" {
  iso_url            = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum       = "none"
  guest_os_type      = "windows11-64"
  vm_name            = "win11-template"
  output_directory   = "/mnt/storage/vmware/win11-template"

  # Force Hardware Version 21 for NVMe/VTPM support on RHEL 10
  virtual_hardware_version = "21"

  # Communicator Fix: Mandatory for Windows builds to avoid SSH errors
  communicator       = "winrm"
  winrm_username     = "admin"
  winrm_password     = var.vm_password
  winrm_timeout      = "2h"
  winrm_use_ssl      = false
  winrm_insecure     = true

  shutdown_command   = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""

  cpus               = 4
  memory             = 12288
  disk_size          = 102400
  disk_adapter_type  = "nvme"
  cdrom_adapter_type = "sata"
  network_adapter_type = "e1000e"
  headless           = true

  # Spamming spacebar to catch the "Press any key to boot from CD" prompt
  boot_wait          = "5s"
  boot_command       = ["<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar>"]

  cd_files = ["./autounattend.xml"]
  cd_label = "AUTOMATION"
  
  vmx_data = {
    "firmware"                = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
    "managedVM.autoAddVTPM"   = "software"
    "bios.bootOrder"          = "cdrom,hdd"
    "sata0:0.present"         = "TRUE"
    "sata0:0.deviceType"      = "cdrom-image"
    "mouse.vusb.type"         = "tablet"
    "usb_xhci.present"        = "TRUE"
  }
}

build {
  sources = ["source.vmware-iso.windows_11"]

  provisioner "powershell" {
    script = "./masgrave.ps1"
  }
}