terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"   # Exact version of the new, rewritten provider
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# ----------------------------------------------------------------------
# Volumes (OS and Data)
# ----------------------------------------------------------------------
resource "libvirt_volume" "windows_os" {
  name = "${var.vm_name}-os.qcow2"
  pool = var.pool_name
  size = var.os_disk_size_gb * 1024 * 1024 * 1024   # bytes (supported in 0.9.1)
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
  machine   = "q35"                     # Native Q35 support
  firmware  = var.firmware_path          # Native UEFI firmware with Secure Boot
  autostart = true

  vcpu   = var.vcpus
  memory = var.memory_mb

  cpu {
    mode = "host-passthrough"            # Native CPU block
  }

  # TPM 2.0 – native block
  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  # Network
  network_interface {
    network_name = var.network_name
    mac          = var.mac_address
  }

  # Disk 1: Windows installation ISO
  disk {
    file = var.iso_path
  }

  # Disk 2: OS disk – SATA bus for driver‑free installation
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

  # UEFI NVRAM – native block
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

  # Video – virtio (drivers from the attached ISO)
  video {
    type = "virtio"
  }

  # --------------------------------------------------------------------
  # Minimal XML patching (XSLT) for SMM and boot order
  # (These are still not exposed natively in 0.9.1)
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

  <!-- Ensure loader has secure='yes' (firmware path already points to secure one, but double‑check) -->
  <xsl:template match="/domain/os/loader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="secure">yes</xsl:attribute>
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
</xsl:stylesheet>
EOF
  }
}