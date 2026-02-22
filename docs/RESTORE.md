# Restore Windows VM from Backup

## Overview

Backups copy both `windows-os.qcow2` and `windows-data.qcow2` to `~/backups/<timestamp>/`.

**Activation**: Windows activation binds to VM hardware (CPU, MAC, disk). Restoring from backup preserves activation as long as hardware is identical.

## Restore Procedure

### 1. Stop the VM

```bash
virsh shutdown windows-thinclient
# Or force:
virsh destroy windows-thinclient
```

### 2. Identify Backup

```bash
ls -la ~/backups/
# Choose timestamp, e.g. 20250222_020000
```

### 3. Replace Disks

**Disks in default pool** (`/var/lib/libvirt/images`):

```bash
BACKUP=~/backups/20250222_020000
DISKS=/var/lib/libvirt/images

# Backup current (optional)
mv $DISKS/windows-os.qcow2 $DISKS/windows-os.qcow2.old
mv $DISKS/windows-data.qcow2 $DISKS/windows-data.qcow2.old

# Restore
cp $BACKUP/windows-os.qcow2 $DISKS/
cp $BACKUP/windows-data.qcow2 $DISKS/
chown libvirt-qemu:libvirt-qemu $DISKS/windows-os.qcow2 $DISKS/windows-data.qcow2
```

### 4. Start VM

```bash
virsh start windows-thinclient
```

### 5. Verify Activation

In Windows: Settings → System → Activation. Should show "Windows is activated."

If activation fails, ensure:
- MAC address unchanged (pinned in Terraform)
- CPU mode unchanged (host-passthrough)
- Same hardware ID
