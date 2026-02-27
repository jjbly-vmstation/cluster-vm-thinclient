terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.3"
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
  # The 'size' attribute is not used in this version. The volume will be created as a sparse file.
}

resource "libvirt_volume" "windows_data" {
  name = "${var.vm_name}-data.qcow2"
  pool = var.pool_name
}

# ----------------------------------------------------------------------
# Domain (VM)
# ----------------------------------------------------------------------
resource "libvirt_domain" "windows" {
  name      = var.vm_name
  # 'machine' and 'firmware' are not supported arguments here.
  # UEFI and machine type must be configured via the loader and XML.
  autostart = true

  vcpu   = var.vcpus
  memory = var.memory_mb

  # CPU configuration is different
  cpu = {
    mode = "host-passthrough"
  }

  # Network Interface
  network_interface {
    network_name = var.network_name
    mac          = var.mac_address
  }

  # Disks are attached differently. The OS and Data volumes must be defined in the 'disk' blocks.
  disk {
    volume_id = libvirt_volume.windows_os.id
  }

  disk {
    volume_id = libvirt_volume.windows_data.id
  }

  # Attach ISOs as separate disks
  disk {
    file = var.iso_path
  }
  disk {
    file = var.virtio_iso_path
  }

  # Graphics and Video
  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
    autoport       = true
  }

  video {
    type = "virtio" # Or "vga" if virtio drivers are not yet installed
  }

  # --------------------------------------------------------------------
  # XML Patching - This is where all the magic happens for 0.9.3
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

  <!-- Add TPM via XML, as the 'tpm' block is not supported -->
  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <tpm model='tpm-tis'>
        <backend type='emulator' version='2.0'/>
      </tpm>
    </xsl:copy>
  </xsl:template>

  <!-- Configure UEFI and Machine Type -->
  <xsl:template match="/domain">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">kvm</xsl:attribute>
      <os>
        <type arch='x86_64' machine='q35'>hvm</type>
        <loader readonly='yes' type='pflash' secure='yes'>${var.firmware_path}</loader>
        <nvram template='${var.nvram_template}'>${var.nvram_file}</nvram>
        <boot dev='cdrom'/>
        <boot dev='hd'/>
        <bootmenu enable='yes' timeout='5000'/>
      </os>
      <xsl:apply-templates select="*[not(self::os)]"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove old device sections that might conflict -->
  <xsl:template match="/domain/devices/emulator"/>
  <xsl:template match="/domain/os"/>
</xsl:stylesheet>
EOF
  }
}