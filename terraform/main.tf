terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~= 0.11.0"   # Use a modern version that supports Windows 11 features
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# ----------------------------------------------------------------------
# Volumes
# ----------------------------------------------------------------------
resource "libvirt_volume" "windows_os" {
  name = "${var.vm_name}-os.qcow2"
  pool = var.pool_name
  size = var.os_disk_size_gb * 1024 * 1024 * 1024   # bytes
}

resource "libvirt_volume" "windows_data" {
  name = "${var.vm_name}-data.qcow2"
  pool = var.pool_name
  size = var.data_disk_size_gb * 1024 * 1024 * 1024
}

# ----------------------------------------------------------------------
# Domain (VM)
# ----------------------------------------------------------------------
resource "libvirt_domain" "windows" {
  name      = var.vm_name
  machine   = "q35"                     # Required for Windows 11
  firmware  = var.firmware_path          # OVMF with Secure Boot support
  autostart = true

  vcpu   = var.vcpus
  memory = var.memory_mb

  cpu {
    mode = "host-passthrough"
  }

  # TPM 2.0 (emulated)
  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  # Network (using your pinned MAC)
  network_interface {
    network_name = var.network_name
    mac          = var.mac_address
  }

  # Disk 1: Windows installation ISO
  disk {
    file = var.iso_path
  }

  # Disk 2: OS disk – attached as SATA (no drivers needed during install)
  disk {
    volume_id  = libvirt_volume.windows_os.id
    target_bus = "sata"
  }

  # Disk 3: Data disk – also SATA
  disk {
    volume_id  = libvirt_volume.windows_data.id
    target_bus = "sata"
  }

  # Disk 4: VirtIO drivers ISO
  disk {
    file = var.virtio_iso_path
  }

  # UEFI NVRAM (a copy of the template is created for this VM)
  nvram {
    file     = var.nvram_file
    template = var.nvram_template
  }

  # Graphics (VNC)
  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
    autoport       = true
  }

  # Video – virtio (drivers will be installed from the virtio‑win ISO)
  video {
    type = "virtio"
  }

  # --------------------------------------------------------------------
  # XML patching (XSLT) – adds SMM and ensures secure loader flag
  # (These are still needed because the provider may not expose them)
  # --------------------------------------------------------------------
  xml {
    xslt = <<EOF
<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Identity transform -->
  <xsl:template match="node()|@*">
    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
  </xsl:template>

  <!-- Add SMM feature (required for Secure Boot + TPM) -->
  <xsl:template match="/domain/features">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <smm state="on"/>
    </xsl:copy>
  </xsl:template>

  <!-- Ensure loader uses pflash and secure='yes' -->
  <xsl:template match="/domain/os/loader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="secure">yes</xsl:attribute>
      <xsl:attribute name="type">pflash</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Set boot order: CDROM first, then hard disk, show boot menu -->
  <xsl:template match="/domain/os">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <boot dev='cdrom'/>
      <boot dev='hd'/>
      <bootmenu enable='yes' timeout='5000'/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove stray <boot> elements under disks -->
  <xsl:template match="/domain/devices/disk/boot"/>
</xsl:stylesheet>
EOF
  }
}