terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# ----------------------------------------------------------------------
# Volumes (use capacity instead of size)
# ----------------------------------------------------------------------
resource "libvirt_volume" "windows_os" {
  name     = "${var.vm_name}-os.qcow2"
  pool     = var.pool_name
  capacity = var.os_disk_size_gb * 1024 * 1024 * 1024   # bytes
}

resource "libvirt_volume" "windows_data" {
  name     = "${var.vm_name}-data.qcow2"
  pool     = var.pool_name
  capacity = var.data_disk_size_gb * 1024 * 1024 * 1024
}

# ----------------------------------------------------------------------
# Domain (VM)
# ----------------------------------------------------------------------
resource "libvirt_domain" "windows" {
  name      = var.vm_name
  type      = "kvm"                     # required argument
  autostart = true

  vcpu   = var.vcpus
  memory = var.memory_mb

  # CPU configuration as a map argument
  cpu = {
    mode = "host-passthrough"
  }

  # TPM as a map argument
  tpm = {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  # Network interfaces as a list of maps
  network_interface = [
    {
      network_name = var.network_name
      mac          = var.mac_address
    }
  ]

  # Disks as a list of maps
  disk = [
    {
      file = var.iso_path               # installation ISO
    },
    {
      volume_id  = libvirt_volume.windows_os.id
      target_bus = "sata"
    },
    {
      volume_id  = libvirt_volume.windows_data.id
      target_bus = "sata"
    },
    {
      file = var.virtio_iso_path        # VirtIO drivers ISO
    }
  ]

  # NVRAM (UEFI var store) as a map argument
  nvram = {
    file     = var.nvram_file
    template = var.nvram_template
  }

  # Graphics as a map argument
  graphics = {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
    autoport       = true
  }

  # Video as a map argument
  video = {
    type = "virtio"
  }

  # XML patching (still works as a map argument)
  xml = {
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
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
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