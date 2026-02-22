#!/bin/bash
# Download Windows ISO to ~/iso
# Usage: ./download-iso.sh <URL> [filename]
# Example: ./download-iso.sh "https://example.com/Win11.iso" Win11_23H2.iso

set -e
ISO_URL="${1:?Usage: $0 <ISO_URL> [filename]}"
ISO_FILENAME="${2:-$(basename "$ISO_URL")}"
ISO_DIR="${HOME}/iso"
mkdir -p "$ISO_DIR"
ISO_DEST="${ISO_DIR}/${ISO_FILENAME}"
echo "Downloading to ${ISO_DEST}..."
wget -O "$ISO_DEST" "$ISO_URL"
echo "Done. ISO: $ISO_DEST"
