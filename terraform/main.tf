# Windows VM on libvirt/KVM (RHEL homelab)
# Two disks: windows-os.qcow2 (OS+activation), windows-data.qcow2 (user data)
# Pinned MAC address for stable activation
#
# terraform init && terraform apply
# If provider errors occur, run: terraform init -upgrade

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
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
  size   = var.os_disk_size_gb * 1024 * 1024 * 1024

  lifecycle {
    prevent_destroy = true
  }
}

# Data disk (persistent user data)
resource "libvirt_volume" "windows_data" {
  name   = "windows-data.qcow2"
  pool   = var.pool_name
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
  firmware = var.firmware_path

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
    template = var.nvram_template
  }

  # Windows 11 requires TPM 2.0
  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0" # Listen on all interfaces
    autoport       = true
  }
  
  # Change from vga to virtio
  video {
    type = "virtio"
  }

xml {
    xslt = <<EOF
<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/features">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <smm state="on"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/os/loader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="secure">yes</xsl:attribute>
      <xsl:attribute name="type">pflash</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/os">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <bootmenu enable='yes' timeout='5000'/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk[@device='cdrom']/target">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="bus">sata</xsl:attribute>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
EOF
  }


}