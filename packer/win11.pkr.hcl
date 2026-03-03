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

  # FIX: Increased wait and spammed spacebar to catch the prompt reliably
  boot_wait          = "5s"
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar>"
  ]

  vnc_bind_address     = "0.0.0.0"
  vnc_port_min         = 5900
  vnc_port_max         = 5900
  vnc_disable_password = true
  
  disk_type_id       = "0"
  cpus               = 4
  memory             = 12288
  disk_size          = 102400 # 100 GB
  disk_adapter_type  = "nvme"
  cdrom_adapter_type = "sata"
  headless           = true

  network_adapter_type = "e1000"
  cd_files = ["./autounattend.xml"]
  cd_label = "AUTOMATION"
  
  vmx_data = {
    "firmware"                = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
    "managedVM.autoAddVTPM"   = "software"
    
    # FORCING BOOT ORDER: This tells EFI to try the CD-ROM before the HDD
    "bios.bootOrder"          = "cdrom,hdd"
    
    # Ensure the NVMe controller is present
    "nvme.present"            = "TRUE"
    
    # Mouse settings for Cockpit/Remmina
    "usb.present"             = "TRUE"
    "usb_xhci.present"        = "TRUE"
    "mouse.vusb.present"      = "TRUE"
    "mouse.vusb.type"         = "tablet"
  }

  vmx_data_post = {
    "bios.bootOrder" = "hdd,cdrom"
  }

  communicator       = "winrm"
  winrm_username     = "admin"
  winrm_password     = var.vm_password
  winrm_timeout      = "4h"
  winrm_use_ssl      = false
  winrm_insecure     = true

  shutdown_command   = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout   = "30m"
}

build {
  sources = ["source.vmware-iso.windows_11"]

  # FIX: This will execute once WinRM is up after the unattended install
  provisioner "powershell" {
    scripts = ["./masgrave.ps1"]
  }
}