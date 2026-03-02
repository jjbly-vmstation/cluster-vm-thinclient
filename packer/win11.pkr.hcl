source "vmware-iso" "windows_11" {
  iso_url          = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  iso_checksum     = "none"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1"
  guest_os_type    = "windows11-64"
  
  vm_name          = "win11-template"
  output_directory = "/home/vmadmin/vmware/win11-template"
  
  cpus             = 4
  memory           = 12288
  disk_size        = 65536
  headless         = false 

  # --- ADD THESE THREE LINES TO FIX THE ERRORS ---
  network_adapter_type = "e1000e"
  ssh_username         = "admin"
  ssh_password         = "placeholder"
  # -----------------------------------------------

  # Tells Packer NOT to wait for SSH/WinRM to finish the build
  communicator         = "none"

  floppy_files     = ["./autounattend.xml"]
  
  vmx_data = {
    "firmware" = "efi"
    "uefi.secureBoot.enabled" = "TRUE"
  }
}