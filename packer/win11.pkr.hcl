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
  iso_url               = "F:/Hyper-V/Virtual Machines/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum          = "none"
  generation            = 2
  enable_secure_boot    = true
  secure_boot_template  = "MicrosoftUEFICertificateAuthority"
  enable_tpm            = true
  vm_name               = "win11-template"
  output_directory      = "F:/Hyper-V/Templates/win11-template"
  cpus                  = 4
  memory                = 12288
  disk_size             = 130048
  switch_name           = "Internal-NAT-Switch"
  first_boot_device = "CD"
  boot_wait         = "10s"
  boot_command      = [""]


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