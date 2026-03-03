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

  # Aggressive spacebar spam to catch the "Press any key to boot from CD" prompt
  boot_wait          = "3s"
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar>"
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
  cdrom_adapter_type = "ide" # IDE is more reliable for booting Windows ISOs in VMware
  headless           = true

  # e1000 is used for built-in driver compatibility to avoid OOBE crashes
  network_adapter_type = "e1000"
  cd_files = ["./autounattend.xml"]
  cd_label = "AUTOMATION"
  
  vmx_data = {
    "firmware"                = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
    "managedVM.autoAddVTPM"   = "software"
    
    # FORCING BOOT ORDER: Ensures the ISO is checked before the empty NVMe drive
    "bios.bootOrder"          = "cdrom,hdd"
    
    # Explicitly enable the primary controller for the ISO
    "ide0:0.present"          = "TRUE"
    "ide0:0.deviceType"       = "cdrom-image"

    # Absolute pointing device for VNC mouse tracking
    "usb.present"             = "TRUE"
    "usb_xhci.present"        = "TRUE"
    "mouse.vusb.present"      = "TRUE"
    "mouse.vusb.type"         = "tablet"
  }

  winrm_username = "admin"
  winrm_password = var.vm_password
  winrm_timeout  = "2h"
  winrm_use_ssl  = false
  winrm_insecure = true
}

build {
  sources = ["source.vmware-iso.windows_11"]

  # Once WinRM is ready, this will execute the activation script
  provisioner "powershell" {
    script = "./masgrave.ps1"
  }
}