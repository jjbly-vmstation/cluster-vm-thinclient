# Cluster VM Thin Client

**Purpose**: Persistent, licensed Windows VM on RHEL (homelab) for thin-client access via MacBook Air.

**Target**: homelab (192.168.4.62) - RHEL 10

VM is stable, activated, backed up, and easy to restore. Mac thin client auto-launches into Windows desktop.

---

## Overview

| Component       | Tool      | Purpose                                      |
|----------------|-----------|----------------------------------------------|
| VM user setup  | Ansible   | Create vmadmin, dirs, groups                 |
| Windows ISO    | Ansible   | Download to ~/iso                            |
| VM provisioning| Terraform | Create qcow2 disks, pinned MAC, prevent_destroy |
| Backups        | Ansible   | Snapshot + copy qcow2 to ~/backups           |
| Windows config | Ansible   | RDP, firewall, folder redirection (post-install) |
| Mac thin client| Scripts   | Auto-login, MS RDP, LaunchAgent              |

---

## Repository Structure

```
cluster-vm-thinclient/
├── README.md                    # This file
├── DEPLOYMENT_RUNBOOK.md        # Step-by-step deployment guide
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml            # Target homelab
│   ├── group_vars/
│   │   └── all.yml              # Variables
│   ├── playbooks/
│   │   ├── 01-vm-user-setup.yml
│   │   ├── 02-download-windows-iso.yml
│   │   ├── 03-backup-windows-vm.yml
│   │   └── 04-windows-hardening.yml   # Run after Windows install + WinRM
│   └── ansible.cfg
├── terraform/
│   ├── main.tf                  # Libvirt Windows VM
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── scripts/
│   ├── download-iso.sh          # Alternative ISO download
│   ├── backup-vm.sh             # Manual backup script
│   └── mac-thinclient/          # Mac auto-launch setup
│       ├── setup-mac-thinclient.sh
│       ├── RDP-profile.example.rdp
│       └── LaunchAgents/
│           └── com.vmstation.windows-rdp.plist
└── docs/
    └── RESTORE.md               # Restore procedure
```

---

## Quick Start

**Base path:** On masternode the repo is typically at `/opt/vmstation-org/cluster-vm-thinclient`. Adjust if you cloned elsewhere (e.g. `~/vmstation-org/cluster-vm-thinclient`).

### Prerequisites

- RHEL 10 host (homelab 192.168.4.62) with libvirt/KVM
- **masternode** (192.168.4.63) – run Ansible and Terraform from here; SSH into homelab as `jashandeepjustinbains` (passwordless sudo)
- Ansible 2.15+ on masternode
- Terraform 1.5+ on masternode (connects to homelab via qemu+ssh)
- Windows ISO (purchased/licensed)
- Windows license key

### SSH Configuration for Terraform

The user running `terraform` on `masternode` needs passwordless SSH access to `homelab` (192.168.4.62) as the `jashandeepjustinbains` user. The libvirt provider will connect using this SSH connection.

**On `masternode` (as the user who will run `terraform`):**

1.  **Generate an SSH key (ed25519 is recommended):**
    If you don't already have one, create it:
    ```bash
    ssh-keygen -t ed25519
    ```
    Accept the defaults by pressing Enter.

2.  **Copy the public key to `homelab`:**
    ```bash
    ssh-copy-id -i ~/.ssh/id_ed25519.pub jashandeepjustinbains@192.168.4.62
    ```
    You will be prompted for the `jashandeepjustinbains` user's password on `homelab`.

3.  **Test the connection:**
    ```bash
    ssh jashandeepjustinbains@192.168.4.62 'hostname'
    ```
    This should return `homelab` without asking for a password.

**Install Terraform on masternode (Debian):**
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
```

### 1. Create VM user and directories

**On masternode** (SSH into homelab as jashandeepjustinbains; become root via sudo):

```bash
cd /opt/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/01-vm-user-setup.yml
```

### 2. Download Windows ISO

```bash
cd /opt/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/02-download-windows-iso.yml \
  -e windows_iso_url="https://example.com/Win11_23H2_English_x64.iso"
```

Or manually place ISO in `~/iso/` on homelab as vmadmin.

### 3. Provision VM with Terraform (from masternode → homelab)

**3a.** Ensure `jashandeepjustinbains` is in the `libvirt` group. Re-run the playbook (it adds this):
```bash
cd /opt/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/01-vm-user-setup.yml
```
Or manually: `ssh jashandeepjustinbains@192.168.4.62 "sudo usermod -aG libvirt jashandeepjustinbains"` (then new SSH sessions will have the group).

**3b.** On masternode, provision the VM:
```bash
cd /opt/vmstation-org/cluster-vm-thinclient/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
# 1. Set the `libvirt_uri` to use your SSH key.
# 2. Set `iso_path` to the full path on homelab (e.g., /home/vmadmin/iso/YourISO.iso).
# 3. Adjust memory, vcpus, etc. as needed.
#
# Example terraform.tfvars content:
# libvirt_uri = "qemu+ssh://jashandeepjustinbains@192.168.4.62/system?keyfile=/home/YOUR_USER_ON_MASTERNODE/.ssh/id_ed25519"
terraform init
terraform apply
```

### 4. Install Windows (manual)

- Boot VM from ISO via virt-manager or virsh
- Install Windows normally
- Install VirtIO drivers if disk/network not detected
- Activate with purchased key in Settings → Activation

### 5. Configure Windows (manual + Ansible)

- Format data disk as D:\
- Redirect user folders to D:\
- Enable RDP (with NLA)
- Enable WinRM for Ansible (see DEPLOYMENT_RUNBOOK.md)
- Run hardening playbook:

```bash
cd /opt/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/04-windows-hardening.yml
```

### 6. Backups

```bash
cd /opt/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/03-backup-windows-vm.yml
```

### 7. Mac thin-client setup

**Option A (recommended)**: Stay on macOS – auto-login, add MS RDP to Login Items, run fullscreen. Dad sees: boot → auto-login → RDP fullscreen → Windows. See [docs/MAC_THIN_CLIENT_OPTIONS.md](docs/MAC_THIN_CLIENT_OPTIONS.md).

**Option B**: Replace macOS with a Linux thin-client OS for a more appliance-like setup (wipes Mac).

```bash
# On MacBook Air (Option A)
./scripts/mac-thinclient/setup-mac-thinclient.sh
```

---

## Activation & Backups

- **Activation** binds to VM virtual hardware (CPU, disk, MAC). Keep MAC pinned and hardware unchanged.
- **Backups** snapshot both qcow2 disks and copy to ~/backups. Activation persists when restoring from backup if hardware is identical.

See [docs/RESTORE.md](docs/RESTORE.md) for restore procedure.

---

## Related Repositories

- [cluster-docs](../cluster-docs) - Central documentation
- [cluster-config](../cluster-config) - RHEL baseline config
- [DEPLOYMENT_GUIDE](../cluster-docs/DEPLOYMENT_GUIDE.md) - Full cluster deployment