packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

# 1. Define the Variable
variable "vm_password" {
  type      = string
  sensitive = true
}

# 2. Configure the Source
source "vmware-iso" "windows_11" {
  iso_url          = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum     = "none"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1"
  guest_os_type    = "windows11-64"
  vm_name          = "win11-template"
  output_directory = "/home/vmadmin/vmware/win11-template"

  shutdown_timeout = "60m"  # Give it up to an hour to finish
  boot_wait        = "15s"  # Wait for the BIOS/UEFI to settle before "typing"

  cpus             = 4
  memory           = 8192
  disk_size        = 65536
  headless         = true

  network_adapter_type = "e1000e"
  ssh_username         = "admin"
  ssh_password         = var.vm_password 
  communicator         = "none" 

  floppy_files         = ["./autounattend.xml"]
  
  vmx_data = {
    "firmware" = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
  }
}

# 3. THE MISSING PIECE: The Build Block
# This is what Packer is complaining is missing!
build {
  sources = ["source.vmware-iso.windows_11"]
}