packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "vm_password" {
  type      = string
  sensitive = true
}

source "hyperv-iso" "win11-enterprise" {
  # Path to your ISO on the NFS share
  iso_url               = "Z:/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum          = "none"
  
  # Generation 2 is required for UEFI/Secure Boot in Win 11
  generation            = 2
  enable_secure_boot    = true
  enable_tpm            = true  
  vm_name               = "win11-template"
  # Local high-speed output directory
  output_directory      = "F:/Hyper-V/Templates/win11-template"
  
  cpus                   = 4
  memory                = 12288
  disk_size             = 130048 # 127 GB
  
  # Matches your internal NAT switch for the 192.168.128.x network
  switch_name           = "Internal-NAT-Switch"
  
  boot_wait             = "3s"
  boot_command          = ["<spacebar><wait><spacebar>"]

  cd_files = [
    "./autounattend.xml",
    "./install_office.ps1",
    "./office_config.xml",
    "./masgrave.ps1"
  ]
  
  communicator          = "winrm"
  winrm_username        = "Administrator"
  winrm_password        = var.vm_password
  winrm_timeout         = "12h"
  winrm_use_ssl         = false
  winrm_insecure        = true

  shutdown_command      = "C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /mode:vm /oobe /shutdown /quiet"
}

build {
  sources = ["source.hyperv-iso.win11-enterprise"]

  provisioner "powershell" {
    scripts = [
      "./install_office.ps1",
      "./masgrave.ps1"
    ]
  }
}