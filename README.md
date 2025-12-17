# VnixOS - Modular NixOS Configuration

A modular, flake-based NixOS configuration supporting multiple desktop environments (GNOME, KDE Plasma, Cosmic) with automated installation and multi-machine management.

## Quick Install

Download and run the installer (always gets the latest version):

```bash
# Using curl (overwrites if file exists)
curl -fsSL https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

Or with wget:

```bash
# Using wget (with -O to overwrite)
wget -O install.sh https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh
chmod +x install.sh
./install.sh
```

**Note**: Both `curl -o` and `wget -O` will overwrite any existing `install.sh` file, ensuring you always have the latest version.

## What It Does

The installer will:

1. Install git (if not already installed)
2. Clone this repository to `/nix/VnixOS/`
3. Enable Nix flakes (if not already enabled)
4. Prompt for:
   - Username and hostname
   - Configuration selection (desktop-gaming, etc.)
   - Desktop environment (GNOME, KDE Plasma, or Cosmic)
5. Auto-detect: timezone, locale, and keyboard layout
6. Auto-login preference
7. Generate `variables.nix` with your settings
8. Generate `hardware-configuration.nix` for your system
9. Validate flake configuration
10. Apply NixOS configuration and reboot

## Features

- **Multiple Desktop Environments**: Choose from GNOME, KDE Plasma, or Cosmic during installation
- **Flake-based**: Modern Nix flakes for reproducible, declarative builds
- **Auto-discovery**: Automatically discovers all configurations in `configurations/` directory
- **Multi-machine**: Manage multiple machines from a single repository
- **Audio**: PipeWire (modern audio server)
- **Networking**: NetworkManager for easy network management
- **Bootloader**: systemd-boot with EFI support
- **Auto-detection**: Automatically detects timezone, locale, and keyboard layout
- **Optional auto-login**: Configure automatic login during installation

## Common Packages

All configurations include:
- Firefox browser
- git, vim, wget, curl
- htop, neofetch
- File manager utilities

## Directory Structure

```
/nix/VnixOS/
├── flake.nix                           # Main flake configuration
├── flake.lock                          # Locked dependencies
├── client/                             # Generated files (per-installation)
│   ├── variables.nix                   # User settings (generated)
│   ├── hardware-configuration.nix      # Hardware config (generated)
│   └── users.nix                       # User management (template)
├── configurations/                     # Configuration profiles
│   └── desktop-gaming/
│       ├── config.nix                  # Main configuration
│       └── applications/
│           └── core.nix                # Desktop-specific packages
├── coresys/                            # Core system modules
│   ├── applications.nix                # Desktop environment selector
│   └── desktop-environments/
│       ├── gnome.nix                   # GNOME configuration
│       ├── kde.nix                     # KDE Plasma configuration
│       └── cosmic.nix                  # Cosmic DE configuration
└── tools/
    ├── install.sh                      # Automated installer
    └── templates/
        ├── variables.nix               # Template for user settings
        └── users.nix                   # Template for user management
```

All files are git-tracked, allowing you to version control your system configuration. Generated files in `client/` contain system-specific information.

## Making Changes

After installation, edit your configuration and apply changes:

### Modify System Configuration

Edit your configuration file:

```bash
# Edit the main configuration
vim /nix/VnixOS/configurations/desktop-gaming/config.nix

# Rebuild and apply changes
sudo nixos-rebuild switch --flake /nix/VnixOS#desktop-gaming
```

### Change Desktop Environment

Edit the generated variables file to change your desktop environment:

```bash
# Edit variables (you can change desktopEnvironment to "gnome", "kde", or "cosmic")
vim /nix/VnixOS/client/variables.nix

# Rebuild with the new desktop environment
sudo nixos-rebuild switch --flake /nix/VnixOS#desktop-gaming
```

### Add Custom Packages

Edit the core applications module:

```bash
# Add packages to your configuration
vim /nix/VnixOS/configurations/desktop-gaming/applications/core.nix

# Rebuild to install new packages
sudo nixos-rebuild switch --flake /nix/VnixOS#desktop-gaming
```

## Multiple Configurations

The flake automatically discovers all configurations in the `configurations/` directory. To create a new configuration:

1. Create a new directory: `mkdir -p /nix/VnixOS/configurations/my-config`
2. Copy the structure from `desktop-gaming/`
3. Customize `config.nix` for your needs
4. Run: `sudo nixos-rebuild switch --flake /nix/VnixOS#my-config`

## Multiple Machines

To use this configuration on multiple machines:

1. Clone the repository on each machine
2. Run `./install.sh` on each system (choose different hostnames)
3. Each system will have its own `client/` directory
4. Edit machine-specific configuration as needed

Each machine can be independently configured and rebuilt using its own hostname.

## Desktop Environment Details

### GNOME
- Display Manager: GDM
- Desktop Manager: GNOME
- Includes: GNOME Tweaks, GNOME Console
- Best for: User-friendly, feature-rich desktop

### KDE Plasma
- Display Manager: SDDM
- Desktop Manager: KDE Plasma 5
- Includes: Konsole, Dolphin, Kate, Plasma Add-ons
- Best for: Customizable, powerful desktop environment

### Cosmic
- Display Manager: Cosmic Greeter
- Desktop Manager: Cosmic DE
- Best for: Modern, lightweight alternative

## Version Control

Your configuration is automatically git-tracked. To save changes:

```bash
cd /nix/VnixOS
git add .
git commit -m "Updated configuration"
```

You can also push to your own remote repository to back up your configuration.

## Troubleshooting

### Flake Not Found
If you get an error about the flake not being found, ensure:
- You're in the `/nix/VnixOS` directory
- The configuration exists in `configurations/`
- Run `nix flake check` to validate the flake

### Desktop Environment Not Loading
If the selected DE doesn't load:
- Check that `/nix/VnixOS/client/variables.nix` has the correct `desktopEnvironment` value
- Ensure the corresponding DE module exists in `coresys/desktop-environments/`
- Run `nixos-rebuild switch --flake /nix/VnixOS#desktop-gaming` with verbose output for more details

## Requirements

- NixOS system (fresh or existing)
- Internet connection
- sudo access (not required to run as root)
- Nix with flakes support (enabled by installer)
