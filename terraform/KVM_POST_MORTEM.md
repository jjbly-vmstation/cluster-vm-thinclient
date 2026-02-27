# KVM/QEMU Post-Mortem & Migration Log

**Date:** 2026-02-27
**Status:** Deprecated / Removed
**Target Platform:** VMware Workstation Pro (RHEL Host)

## Rationale
The KVM/QEMU virtualization stack was abandoned due to significant friction with documentation quality and configuration complexity. The decision was made to switch to VMware Workstation Pro for better stability and ease of management on the RHEL homelab node.

## Deprecated Stack Details
- **Provider:** `dmacvicar/libvirt`
- **Connection:** `qemu:///system`
- **Storage:** QCOW2 volumes in default pool
- **Firmware:** OVMF (Secure Boot)

## Cleanup Actions
1. Removed `libvirt` provider configuration from Terraform.
2. Removed `libvirt_domain` and `libvirt_volume` resources.
3. Updated Ansible playbooks to remove KVM packages (`libvirt`, `qemu-kvm`).
4. Updated Ansible playbooks to install VMware prerequisites (`kernel-headers`, `gcc`).

This directory now contains Terraform configuration for the `elsudano/vmworkstation` provider.