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
  iso_url           = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum      = "none"   # Use "sha256:..." for production
  guest_os_type     = "windows11-64"
  vm_name           = "win11-template"
  output_directory  = "/home/vmadmin/vmware/win11-template"

  # Boot order: wait 3s, then press space to boot from CD
  boot_wait         = "3s"
  boot_command = [
    "<spacebar><wait><wait>"
  ]

  vnc_bind_address  = "0.0.0.0"
  vnc_port_min      = 5900
  vnc_port_max      = 5900
  vnc_disable_password = true   # No password required for VNC
  
  
  cpus              = 4
  memory            = 12288
  disk_size         = 100 * 1024   # 100 GB
  headless          = true        # Set false to see the console (debug)

  network_adapter_type = "e1000e"
  cd_files = ["./autounattend.xml"]
  cd_label = "AUTOMATION"
  
  
  
  vmx_data = {
    "firmware"                = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
    "managedVM.autoAddVTPM"   = "software"
    "bios.bootOrder"          = "hdd,cdrom"
  }
  vmx_data_post = {
    "bios.bootOrder" = "hdd,cdrom"
  }

  # WinRM communicator – Windows will be configured to accept WinRM in autounattend
  communicator       = "winrm"
  winrm_username     = "admin"
  winrm_password     = var.vm_password
  winrm_timeout      = "4h"
  winrm_use_ssl      = false
  winrm_insecure     = true

  # Shutdown command will be executed via WinRM after provisioning
  shutdown_command   = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout   = "30m"
}

build {
  sources = ["source.vmware-iso.windows_11"]

  # Optional: provisioners to run Masgrave after WinRM is ready
  provisioner "powershell" {
    scripts = ["./masgrave.ps1"]
  }
}