terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.0"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# OS disk (Windows + activation)
resource "libvirt_volume" "windows_os" {
  name = "windows-os.qcow2"
  pool = "default"
  size = 68719476736

  lifecycle {
    prevent_destroy = true
  }
}

# Data disk (persistent user data)
resource "libvirt_volume" "windows_data" {
  name = "windows-data.qcow2"
  pool = "default"
  size = 107374182400

  lifecycle {
    prevent_destroy = true
  }
}

# Windows VM
resource "libvirt_domain" "windows" {
  name     = var.vm_name
  memory   = var.memory_mb
  vcpu     = var.vcpus
  type     = "kvm"
  machine  = "q35"
  firmware = var.firmware_path

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name = var.network_name
    mac          = var.mac_address
  }
  
  
  # 1. Windows Installer ISO (Set to SATA)
  disk {
    file       = "/home/vmadmin/iso/en-us_windows_11_business_editions_version_25h2_updated_feb_2026_x64_dvd_9271bf68.iso"
  }

  # 2. OS Disk (Set to VirtIO for performance)
  disk {
    volume_id  = libvirt_volume.windows_os.id
  }

  # 3. VirtIO Drivers ISO (Set to SATA)
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

  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
    autoport       = true
  }
  
  video {
    type = "vga"
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

  <xsl:template match="/domain/devices/disk/target[@bus='ide']">
    <target bus='sata'>
      <xsl:attribute name="dev">
        <xsl:value-of select="@dev"/>
      </xsl:attribute>
    </target>
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