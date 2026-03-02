packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "windows_11" {
  iso_url          = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum     = "none"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1"
  guest_os_type    = "windows11-64"
  
  vm_name          = "win11-template"
  output_directory = "/home/vmadmin/vmware/win11-template"
  memory           = 8192
  cpus             = 4
  disk_size        = 65536
  headless         = false 

  floppy_files     = ["./autounattend.xml"]
  
  vmx_data = {
    "firmware" = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
  }
}

build {
  sources = ["source.vmware-iso.windows_11"]
}