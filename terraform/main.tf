# Windows 11 VM on libvirt/KVM (RHEL 9+ Host)
# Requirements: OVMF (UEFI/Secure Boot) and swtpm (TPM Emulator) installed on host

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

# --- Storage ---

resource "libvirt_volume" "windows_os" {
  name   = "${var.vm_name}-os.qcow2"
  pool   = "default"
  size   = 68719476736 # 64GB
  format = "qcow2"

  lifecycle {
    prevent_destroy = true
  }
}

# --- Domain Definition ---

resource "libvirt_domain" "windows" {
  name   = var.vm_name
  memory = var.memory_mb
  vcpu   = var.vcpus
  type   = "kvm"
  machine = "q35" # Modern chipset for Windows 11
  firmware = var.firmware_path # Path to OVMF_CODE.secboot.fd

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name = var.network_name
    mac          = var.mac_address # Pinned for licensing stability
    wait_for_lease = false
  }

  # 1. Windows Installer ISO
  disk {
    file = "/home/vmadmin/iso/windows_11_install.iso"
  }

  # 2. Main OS Storage
  disk {
    volume_id = libvirt_volume.windows_os.id
  }

  # 3. VirtIO Drivers (Essential for storage/network performance)
  disk {
    file = "/home/vmadmin/iso/virtio-win.iso"
  }

  nvram {
    file     = "/var/lib/libvirt/qemu/nvram/${var.vm_name}_VARS.fd"
    template = var.nvram_template # Path to OVMF_VARS.fd
  }

  # Windows 11 Requirement
  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  video {
    type = "vga" # Use VGA for install, switch to virtio after drivers are loaded
  }

  # --- Hardware Patching (Robustness Layer) ---
  # This XSLT fixes issues where the provider defaults to IDE or 
  # fails to set Secure Boot flags correctly for RHEL's QEMU.
  xml {
    xslt = <<EOF
<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk/boot"/>

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

  <xsl:template match="/domain/devices/disk/target">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="bus">sata</xsl:attribute>
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