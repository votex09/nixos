# NixOS GNOME Configuration

A simple, modular NixOS configuration with GNOME desktop environment.

## Quick Install

Run this one-liner to install:

```bash
curl -fsSL https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh | bash
```

## What It Does

The installer will:

1. Install git (if not already installed)
2. Clone this repository to `/home/.VnixOS/`
3. Auto-detect your timezone, locale, and keyboard layout
4. Prompt for username and hostname
5. Generate `hardware-configuration.nix` for your system
6. Generate `configuration.nix` with your settings
7. Optionally rebuild your system

## Features

- **Desktop Environment**: GNOME with GDM display manager
- **Audio**: PipeWire (modern audio server)
- **Networking**: NetworkManager
- **Bootloader**: systemd-boot with EFI support
- **Flakes**: Enabled for reproducible builds

## Default Packages

- Firefox
- GNOME Tweaks
- vim, wget, git
- gnome-console

## Directory Structure

```
/home/.VnixOS/
├── flake.nix                   # Flake configuration
├── flake.lock                  # Locked dependencies
├── configuration.nix           # Main system configuration
├── system/
│   └── hardware-configuration.nix  # Auto-generated hardware config
├── applications/
│   ├── core.nix               # Essential system packages (do not modify)
│   └── user.nix               # User-defined custom packages (optional)
└── tools/
    └── install.sh              # Installation script
```

All files are git-tracked, allowing you to version control your system configuration.

## Making Changes

After installation, edit files in `/home/.VnixOS/` and apply changes:

```bash
# Edit your configuration
vim /home/.VnixOS/configuration.nix

# Apply changes
sudo nixos-rebuild switch --flake /home/.VnixOS#YOUR_HOSTNAME
```

## Customization

**Main Configuration**: Edit `/home/.VnixOS/configuration.nix` to:
- Change desktop environment settings
- Configure services
- Add more users
- Modify system-level settings

**Core Packages**: `/home/.VnixOS/applications/core.nix`
- Contains essential system packages
- Do not remove these unless you know what you're doing

**Custom Packages**: Edit `/home/.VnixOS/applications/user.nix` to:
- Add your personal applications
- Customize packages for your workflow
- Safely modify without affecting core system

## Version Control

Your configuration is automatically git-tracked. To save changes:

```bash
cd /home/.VnixOS
git add .
git commit -m "Updated configuration"
```

You can also push to your own remote repository to back up your configuration.

## Requirements

- NixOS system (fresh or existing)
- Internet connection
- Root/sudo access
