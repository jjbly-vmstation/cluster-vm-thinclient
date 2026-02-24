# Windows VM on libvirt/KVM (RHEL homelab)
# Two disks: windows-os.qcow2 (OS+activation), windows-data.qcow2 (user data)
# Pinned MAC address for stable activation
#
# terraform init && terraform apply

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.6"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# OS disk (Windows + activation) - empty qcow2 for fresh install
resource "libvirt_volume" "windows_os" {
  name   = "windows-os.qcow2"
  pool   = var.pool_name
  format = "qcow2"
  size   = var.os_disk_size_gb * 1024 * 1024 * 1024

  lifecycle {
    prevent_destroy = true
  }
}

# Data disk (persistent user data)
resource "libvirt_volume" "windows_data" {
  name   = "windows-data.qcow2"
  pool   = var.pool_name
  format = "qcow2"
  size   = var.data_disk_size_gb * 1024 * 1024 * 1024

  lifecycle {
    prevent_destroy = true
  }
}

# Windows VM
resource "libvirt_domain" "windows" {
  name   = var.vm_name
  memory = var.memory_mb
  vcpu   = var.vcpus
  type   = "kvm"
  machine = "q35"
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  # Pinned MAC address - critical for Windows activation
  network_interface {
    network_name = var.network_name
    mac          = var.mac_address
  }
  boot_device {
    dev = ["cdrom", "hd"]
  }

  # OS disk (virtio)
  disk {
    volume_id = libvirt_volume.windows_os.id
  }

  # Data disk (virtio)
  disk {
    volume_id = libvirt_volume.windows_data.id
  }

  # Windows installation ISO — SATA CD-ROM
  disk {
    file = var.iso_path
  }

  # VirtIO drivers ISO — second SATA CD-ROM
  disk {
    file = "/home/vmadmin/iso/virtio-win.iso"
  }


  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  nvram {
    file     = "/home/vmadmin/disks/windows-vars.fd"
    template = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
  }

  # Windows 11 requires TPM 2.0
  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "127.0.0.1" 
    autoport       = true
  }

  video {
    type = "virtio"
  }
}
