# NixOS GNOME Configuration

A simple, modular NixOS configuration with GNOME desktop environment.

## Quick Install

Download and run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

Or with wget:

```bash
wget https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh
chmod +x install.sh
./install.sh
```

## What It Does

The installer will:

1. Install git (if not already installed)
2. Clone this repository to `/nix/VnixOS/`
3. Auto-detect your timezone, locale, and keyboard layout
4. Prompt for username and hostname
5. Generate `hardware-configuration.nix` for your system
6. Generate `configuration.nix` with your settings
7. Rebuild your system and reboot

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
/nix/VnixOS/
├── flake.nix                   # Flake configuration (auto-discovers hosts)
├── flake.lock                  # Locked dependencies
├── hosts/
│   ├── desktop/                # Per-host configuration
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── laptop/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── ...
├── applications/
│   ├── core.nix               # Essential system packages (do not modify)
│   └── user.nix               # User-defined custom packages (optional)
└── tools/
    └── install.sh              # Installation script
```

All files are git-tracked, allowing you to version control your system configuration. Each machine's configuration is kept separate in its own `hosts/HOSTNAME/` directory.

## Making Changes

After installation, edit files in your host directory and apply changes:

```bash
# Edit your configuration (replace 'desktop' with your hostname)
vim /nix/VnixOS/hosts/desktop/configuration.nix

# Apply changes
sudo nixos-rebuild switch --flake /nix/VnixOS#desktop
```

## Multiple Machines

The flake automatically discovers all host configurations in the `hosts/` directory. To add a second machine:

1. Clone the repository on the second machine
2. Run `./install.sh` again with a different hostname
3. The installer creates a new host directory without overwriting existing configurations
4. Both machines can be managed from the same repository

You can rebuild either machine from any location:
```bash
# Rebuild desktop from laptop
sudo nixos-rebuild switch --flake /path/to/VnixOS#desktop

# Rebuild laptop from desktop
sudo nixos-rebuild switch --flake /path/to/VnixOS#laptop
```

## Customization

**Host Configuration**: Edit `/nix/VnixOS/hosts/YOUR_HOSTNAME/configuration.nix` to:
- Change desktop environment settings
- Configure services
- Add more users
- Modify system-level settings

**Core Packages**: `/nix/VnixOS/applications/core.nix`
- Contains essential system packages (shared across all hosts)
- Do not remove these unless you know what you're doing

**Custom Packages**: Edit `/nix/VnixOS/applications/user.nix` to:
- Add your personal applications (shared across all hosts)
- Customize packages for your workflow
- Safely modify without affecting core system

## Version Control

Your configuration is automatically git-tracked. To save changes:

```bash
cd /nix/VnixOS
git add .
git commit -m "Updated configuration"
```

You can also push to your own remote repository to back up your configuration.

## Requirements

- NixOS system (fresh or existing)
- Internet connection
- Root/sudo access
