# MacBook Air Thin-Client Options

**Goal**: MacBook boots and goes straight to the Windows VM desktop, with minimal or no macOS interaction.

---

## Option A: Stay on macOS, Auto-Launch RDP (Recommended)

**No reinstall required.** macOS stays on the Mac; you configure it so that on login, Microsoft Remote Desktop opens and connects fullscreen.

### How it works

1. **Auto-login**: System Settings → Users & Groups → Login Options → Automatic login (choose dad’s account)
2. **Login Items**: System Settings → Users & Groups → [User] → Login Items → Add “Microsoft Remote Desktop”
3. **LaunchAgent** (optional): At login, launch MS RDP and optionally connect to your saved RDP session
4. **Fullscreen RDP**: When connected, RDP runs fullscreen so only the Windows desktop is visible

### User experience

- Power on → macOS boot (15–30 s) → auto-login → MS RDP opens and connects → fullscreen Windows
- Dad interacts only with Windows (fullscreen RDP)
- macOS is still present, but effectively invisible during use
- No Linux install or hardware change

### Limitation

- A few seconds of macOS boot and login before RDP appears
- If RDP disconnects, macOS desktop is visible until reconnecting

---

## Option B: Replace macOS with a Linux Thin-Client OS

**Wipe macOS** and install a Linux distro that boots directly to an RDP session.

### How it works

1. Create a USB installer for Ubuntu, Fedora, or a thin-client distro (e.g. Thinstation)
2. Install Linux on the MacBook (replacing macOS)
3. Auto-login to a minimal desktop or straight to an RDP client
4. Use Remmina, FreeRDP, or Microsoft RDP for Linux; connect to the Windows VM and run fullscreen

### User experience

- Power on → GRUB/boot → Linux login → RDP fullscreen
- Typically faster boot than macOS
- More “appliance-like” than macOS

### Pros and cons

- **Pros**: Lighter than macOS, often faster boot, no macOS footprint
- **Cons**: Lose macOS; GRUB/boot splash still visible briefly

### Thin-client distros

- **Thinstation**: Designed for thin clients; PXE or USB boot, minimal X + RDP
- **Ubuntu minimal / Fedora minimal**: Small install, then configure auto-login + RDP client
- **WTWare**: Commercial, purpose-built thin-client OS

---

## Option C: Single-App / Kiosk Mode on macOS

Tighten macOS so only MS RDP runs and it feels like a single-purpose device.

### Approaches

1. **Login Items + Restrictions**: Auto-login, add MS RDP to Login Items, optionally use Screen Time or Parental Controls to limit other apps
2. **DEP + Single App Mode**: For enterprise/DEP-managed Macs only; not typical for home

For a home Mac, Option A (Login Items + fullscreen RDP) achieves almost the same result with less complexity.

---

## Recommendation

**Option A** is usually best:

1. No need to wipe macOS; reversible and safe
2. Dad’s flow: power on → auto-login → RDP fullscreen → Windows
3. Setup is: auto-login, add MS RDP to Login Items, create saved RDP connection, fullscreen
4. Use the `setup-mac-thinclient.sh` LaunchAgent to open MS RDP at login

If you want the most appliance-like setup and are okay losing macOS, **Option B** (Linux thin client) is an alternative.
