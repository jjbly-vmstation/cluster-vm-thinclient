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
  # Change to the absolute path of your ISO
  iso_url            = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum       = "none"
  guest_os_type      = "windows11-64"
  vm_name            = "win11-template"
  output_directory   = "/mnt/storage/vmware/win11-template"

  # Communicator Fix: Tells Packer to use WinRM instead of SSH
  communicator       = "winrm"
  winrm_username     = "admin"
  winrm_password     = var.vm_password
  winrm_timeout      = "2h"
  winrm_use_ssl      = false
  winrm_insecure     = true

  # Graceful shutdown for Terraform preparation
  shutdown_command   = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""

  # Hardware Configuration
  cpus               = 4
  memory             = 12288
  disk_size          = 102400
  disk_adapter_type  = "nvme"
  cdrom_adapter_type = "ide"
  network_adapter_type = "e1000"
  headless           = true

  # Boot Logic
  boot_wait          = "3s"
  boot_command       = ["<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar>"]

  cd_files = ["./autounattend.xml"]
  cd_label = "AUTOMATION"
  
  vmx_data = {
    "firmware"                = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
    "managedVM.autoAddVTPM"   = "software"
    "bios.bootOrder"          = "cdrom,hdd"
    "ide0:0.present"          = "TRUE"
    "ide0:0.deviceType"       = "cdrom-image"
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