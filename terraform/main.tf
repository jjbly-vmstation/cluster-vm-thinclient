terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.2"   # or 0.9.1 – both use the same schema
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
  name     = "${var.vm_name}-os.qcow2"
  pool     = var.pool_name
  capacity = var.os_disk_size_gb * 1024 * 1024 * 1024   # bytes
  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "windows_data" {
  name     = "${var.vm_name}-data.qcow2"
  pool     = var.pool_name
  capacity = var.data_disk_size_gb * 1024 * 1024 * 1024
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# ----------------------------------------------------------------------
# Domain (VM)
# ----------------------------------------------------------------------
resource "libvirt_domain" "windows" {
  name      = var.vm_name
  type      = "kvm"
  vcpu      = var.vcpus
  memory    = var.memory_mb
  autostart = true

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"

    loader          = var.firmware_path
    loader_type     = "pflash"
    loader_readonly = "yes"
    loader_secure   = "yes"

    boot_devices = [
      { dev = "cdrom" },
      { dev = "hd" }
    ]

    bootmenu = {
      enable  = "yes"
      timeout = "5000"
    }

    nv_ram = {
      file     = var.nvram_file
      template = var.nvram_template
      format   = { type = "raw" }
    }
  }

  # Devices (disks, interfaces, TPM, graphics, video)
  devices = {
    # Disks (list of objects)
    disks = [
      # Installation ISO (CDROM)
      {
        source = {
          file = {
            file = var.iso_path
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        type = "cdrom"   # or device = "cdrom" – check docs
      },
      # OS disk (from volume)
      {
        source = {
          volume = {
            pool   = var.pool_name
            volume = libvirt_volume.windows_os.name
          }
        }
        target = {
          dev = "sdb"
          bus = "sata"
        }
      },
      # Data disk (from volume)
      {
        source = {
          volume = {
            pool   = var.pool_name
            volume = libvirt_volume.windows_data.name
          }
        }
        target = {
          dev = "sdc"
          bus = "sata"
        }
      },
      # VirtIO drivers ISO (CDROM)
      {
        source = {
          file = {
            file = var.virtio_iso_path
          }
        }
        target = {
          dev = "sdd"
          bus = "sata"
        }
        type = "cdrom"
      }
    ]

    # Network interfaces (list of objects)
    interfaces = [
      {
        source = {
          network = {
            network = var.network_name
          }
        }
        mac = {
          address = var.mac_address
        }
        model = {
          type = "virtio"
        }
        # wait_for_ip = {}  # optional
      }
    ]

    # TPM 2.0 (list of objects)
    tpms = [
      {
        backend = {
          emulator = {}
        }
        # The version attribute is set at the TPM device level
        version = "2.0"
      }
    ]

    # Graphics (VNC)
    graphics = [
      {
        type        = "vnc"
        listen_type = "address"
        listen_address = "0.0.0.0"
        autoport    = true
      }
    ]

    # Video (virtio)
    videos = [
      {
        model = {
          type = "virtio"
        }
      }
    ]
  }

  features = {
    acpi = true
    smm = { state = "on" }   # ✅ object with state
  }

}