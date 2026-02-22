#!/bin/bash
# Backup Windows VM qcow2 disks
# Run on homelab as root or vmadmin (with libvirt access)
# Usage: ./backup-vm.sh [disks_dir] [backup_dir]

VM_NAME="${VM_NAME:-windows-thinclient}"
DISKS_DIR="${1:-/var/lib/libvirt/images}"
BACKUP_DIR="${2:-$HOME/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEST="${BACKUP_DIR}/${TIMESTAMP}"

mkdir -p "$DEST"

echo "Backing up VM disks to ${DEST}..."
for disk in windows-os.qcow2 windows-data.qcow2; do
  SRC="${DISKS_DIR}/${disk}"
  if [ -f "$SRC" ]; then
    cp "$SRC" "$DEST/"
    echo "  Copied $disk"
  else
    echo "  Skip $disk (not found)"
  fi
done
echo "Backup complete: $DEST"
