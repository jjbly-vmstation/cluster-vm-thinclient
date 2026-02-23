# Windows VM Thin-Client Deployment Runbook

**Target**: homelab (192.168.4.62) - RHEL 10  
**Result**: Persistent, licensed Windows VM + Mac thin-client auto-launch

---

## Checklist Overview

| Step | Task                         | Automated | Est. Time |
|------|------------------------------|-----------|-----------|
| 1    | Create dedicated VM user     | Ansible   | 2 min     |
| 2    | Download Windows ISO         | Ansible   | 15–30 min |
| 3    | Terraform VM setup           | Terraform | 5 min     |
| 4    | Install Windows              | Manual    | 30–45 min |
| 5    | Activate Windows             | Manual    | 2 min     |
| 6    | Configure Windows            | Manual + Ansible | 20 min |
| 7    | Hardening + automation       | Ansible   | 10 min    |
| 8    | Backups                      | Ansible   | 5 min     |
| 9    | Mac thin-client setup        | Script    | 10 min    |

---

## Step 1: Create Dedicated VM User on RHEL

**Commands (manual):**
```bash
useradd -m -s /bin/bash vmadmin
usermod -aG libvirt,kvm vmadmin
mkdir -p /home/vmadmin/{iso,disks,terraform,backups}
chown -R vmadmin:vmadmin /home/vmadmin/{iso,disks,terraform,backups}
```

**Automated (Ansible) – run from masternode:**
```bash
cd ~/vmstation-org/cluster-vm-thinclient/ansible
ansible-playbook -i inventory/hosts.yml playbooks/01-vm-user-setup.yml
```
Connects to homelab as `jashandeepjustinbains`; uses `become` (sudo) for root tasks.

Creates:
- User: `vmadmin`
- Groups: `libvirt`, `kvm`
- Dirs: `~/iso`, `~/disks`, `~/terraform`, `~/backups`

---

## Step 2: Download Windows ISO

Place ISO in `~/iso/` (as vmadmin or root).

**Options:**
- Download from Microsoft (VLSC/retail) and copy via scp
- Use Ansible playbook with `windows_iso_url` (provide valid URL)

```bash
ansible-playbook -i inventory/hosts.yml playbooks/02-download-windows-iso.yml \
  -e "windows_iso_url=https://your-valid-url/Win11_23H2.iso"
```

**Manual copy:**
```bash
scp Win11_23H2_English_x64.iso vmadmin@192.168.4.62:~/iso/
```

---

## Step 3: Terraform VM Setup

**Disks:**
- `windows-os.qcow2` – OS + activation
- `windows-data.qcow2` – Persistent user data

**Terraform config:**
- Pinned MAC address
- `prevent_destroy = true`
- ISO attached for first boot

```bash
cd cluster-vm-thinclient/terraform
rm -rf .terraform .terraform.lock.hcl
cp terraform.tfvars.example terraform.tfvars
# Edit: iso_path, disk sizes, memory, vcpus
# Note that there is a bug with terraform v0.7.6 that requires the ssh key to be in RSA format and ignores known_hosts_verify as well as keyfile parameters
terraform init -upgrade
terraform apply
# TF_LOG=DEBUG terraform apply
```

---

## Step 4: Install Windows

1. Boot VM (virt-manager or virsh).
2. Install from ISO. If disk/network not visible, load VirtIO drivers:
   - https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/
   - Add virtio-win ISO, load drivers during install.
3. Complete setup (locale, user, etc.).

---

## Step 5: Activate Windows

1. Settings → System → Activation.
2. Enter purchased key.
3. Activation binds to VM virtual hardware.

**Important**: Keep MAC and hardware stable. Changing them may deactivate.

---

## Step 6: Configure Windows

1. **Format data disk as D:\\**
   - Disk Management → New Simple Volume → D:\

2. **Redirect user folders to D:\\**
   - Right-click Desktop/Documents/Downloads → Properties → Location → Move to D:\

3. **Enable RDP (with NLA)**
   - Settings → System → Remote Desktop → Enable
   - Ensure "Require Network Level Authentication" is on

4. **Join FreeIPA domain (optional)**
   - Use cluster-config/FreeIPA docs if deployed

---

## Step 7: Hardening + Automation (Ansible)

**Prerequisite**: WinRM enabled on Windows VM.

**Enable WinRM (PowerShell as Admin):**
```powershell
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force  # Or restrict to homelab IP
```

**Run Ansible playbook:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/04-windows-hardening.yml
```

Tasks:
- RDP configuration
- Firewall rules
- Optional app installs (Chocolatey)
- Updates
- Folder redirection (if not done manually)

---

## Step 8: Backups

**One-time:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/03-backup-windows-vm.yml
```

** cron (on homelab as vmadmin):**
```bash
0 2 * * * /home/vmadmin/cluster-vm-thinclient/scripts/backup-vm.sh
```

Backup contents:
- Snapshot both qcow2 disks
- Copy to ~/backups/ with timestamp

---

## Step 9: Mac Thin-Client Setup

**Do I need a Linux thin-client OS?** No. You can stay on macOS and still have the Mac behave like a thin client: auto-login → MS RDP fullscreen → Windows. Dad interacts only with Windows. See [docs/MAC_THIN_CLIENT_OPTIONS.md](docs/MAC_THIN_CLIENT_OPTIONS.md) for Option B (replace macOS with Linux) if you want a more appliance-like setup.

**Option A (recommended – stay on macOS):**
1. Enable auto-login (System Settings → Users & Groups → Login Options).
2. Install Microsoft Remote Desktop from Mac App Store.
3. Create RDP profile (save connection to `192.168.4.62` or VM IP; user, full screen).
4. Add MS RDP to Login Items so it opens at login.
5. Optional LaunchAgent:

```bash
./scripts/mac-thinclient/setup-mac-thinclient.sh 192.168.4.62
```

Configure: RDP host, Windows username, full screen.

---

## Restore Procedure

See [docs/RESTORE.md](docs/RESTORE.md).

1. Stop VM.
2. Replace qcow2 disks from ~/backups.
3. Start VM. Activation should persist if hardware unchanged.
