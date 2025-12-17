#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run this script as root. It will use sudo when needed."
    exit 1
fi

# Check if running on NixOS
if [ ! -f /etc/NIXOS ]; then
    print_error "This script must be run on NixOS"
    exit 1
fi

print_info "VnixOS Flake Configuration Installer"
echo ""

# Fixed installation directory
CONFIG_DIR="/nix/VnixOS"
REPO_URL="https://github.com/votex09/nixos.git"

print_info "Configuration directory: $CONFIG_DIR"

# Install git if not already installed
if ! command -v git &> /dev/null; then
    print_info "Git not found. Installing git..."
    nix-env -iA nixos.git
    print_success "Git installed"
else
    print_info "Git is already installed"
fi

# Check if already installed
if [ -d "$CONFIG_DIR" ]; then
    print_error "NixOS configuration appears to be already installed at $CONFIG_DIR"
    print_error "This installer is designed for fresh systems only."
    print_info "If you want to reinstall, manually remove $CONFIG_DIR first (sudo rm -rf $CONFIG_DIR)."
    exit 1
fi

# Create the directory with proper permissions
print_info "Creating configuration directory..."
sudo mkdir -p "$CONFIG_DIR"
sudo chown root:wheel "$CONFIG_DIR"
sudo chmod 775 "$CONFIG_DIR"
print_success "Directory created with wheel group write access"

# Clone repository
print_info "Cloning repository to $CONFIG_DIR"
git clone "$REPO_URL" "$CONFIG_DIR"
print_success "Repository cloned"

# Now gather user information
print_info "Gathering user information..."
CURRENT_USER=$(whoami)
print_info "Current user: $CURRENT_USER"
echo ""

# Get username for configuration
echo -n "Enter username for NixOS configuration [$CURRENT_USER]: "
read USERNAME
USERNAME=${USERNAME:-$CURRENT_USER}

# Get hostname
CURRENT_HOSTNAME=$(hostname)
echo -n "Enter hostname for this system [$CURRENT_HOSTNAME]: "
read HOSTNAME
HOSTNAME=${HOSTNAME:-$CURRENT_HOSTNAME}
echo ""

# Get list of available configurations
print_info "Available configurations:"
CONFIGS=($(find "$CONFIG_DIR/configurations" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
if [ ${#CONFIGS[@]} -eq 0 ]; then
    print_error "No configurations found in $CONFIG_DIR/configurations"
    exit 1
fi

for i in "${!CONFIGS[@]}"; do
    echo "  $((i+1)). ${CONFIGS[$i]}"
done
echo ""

# Get user requested device configuration
echo -n "Select configuration (1-${#CONFIGS[@]}) or enter custom name: "
read CONFIG_INPUT
CONFIG_INPUT=${CONFIG_INPUT:-1}

# Check if input is a number
if [[ "$CONFIG_INPUT" =~ ^[0-9]+$ ]]; then
    if [ "$CONFIG_INPUT" -ge 1 ] && [ "$CONFIG_INPUT" -le ${#CONFIGS[@]} ]; then
        CONFIGURATION=${CONFIGS[$((CONFIG_INPUT-1))]}
    else
        print_error "Invalid selection"
        exit 1
    fi
else
    CONFIGURATION=$CONFIG_INPUT
fi
print_info "Selected configuration: $CONFIGURATION"
echo ""

# Desktop Environment selection
print_info "Available desktop environments:"
echo "  1. GNOME"
echo "  2. KDE Plasma"
echo "  3. Cosmic"
echo ""
echo -n "Select desktop environment (1-3) [1]: "
read DE_INPUT
DE_INPUT=${DE_INPUT:-1}

case $DE_INPUT in
  1) DESKTOP_ENV="gnome" ;;
  2) DESKTOP_ENV="kde" ;;
  3) DESKTOP_ENV="cosmic" ;;
  *) print_error "Invalid selection"; exit 1 ;;
esac
print_info "Selected desktop environment: $DESKTOP_ENV"
echo ""

# Auto-detect timezone
TIMEZONE=$(timedatectl show -p Timezone --value 2>/dev/null || echo "America/New_York")
print_info "Auto-detected timezone: $TIMEZONE"

# Auto-detect locale
LOCALE=$(localectl status | grep "System Locale" | cut -d= -f2 | cut -d. -f1-2 | head -n1)
if [ -z "$LOCALE" ]; then
    LOCALE="en_US.UTF-8"
fi
print_info "Auto-detected locale: $LOCALE"

# Auto-detect keyboard layout
KB_LAYOUT=$(localectl status | grep "X11 Layout" | awk '{print $3}')
if [ -z "$KB_LAYOUT" ]; then
    KB_LAYOUT="us"
fi
print_info "Auto-detected keyboard layout: $KB_LAYOUT"

# Ask about auto-login
echo -n "Enable auto-login for $USERNAME? (y/N): "
read AUTOLOGIN
AUTOLOGIN=${AUTOLOGIN,,}  # Convert to lowercase

echo ""
print_info "Configuration Summary:"
echo "  Username:              $USERNAME"
echo "  Hostname:              $HOSTNAME"
echo "  Config:                $CONFIGURATION"
echo "  Desktop Environment:   $DESKTOP_ENV"
echo "  Timezone:              $TIMEZONE"
echo "  Locale:                $LOCALE"
echo "  Keyboard Layout:       $KB_LAYOUT"
echo "  Auto-login:            $([ "$AUTOLOGIN" = "y" ] && echo "Yes" || echo "No")"
echo ""

echo -n "Continue with installation? (y/N): "
read CONFIRM
CONFIRM=${CONFIRM,,}

if [ "$CONFIRM" != "y" ]; then
    print_warning "Installation cancelled"
    exit 0
fi

echo ""
print_info "Starting system configuration..."

# Enable flakes permanently
print_info "Enabling flakes in system configuration..."
if ! grep -q "experimental-features = \[ \"nix-command\" \"flakes\" \]" /etc/nixos/configuration.nix; then
    sudo sed -i '/^}/i\  nix.settings.experimental-features = [ "nix-command" "flakes" ];' /etc/nixos/configuration.nix
    print_info "Rebuilding system to enable flakes..."
    sudo nixos-rebuild switch
    print_success "Flakes enabled"
else
    print_info "Flakes already enabled"
fi

# Generate hardware-configuration.nix
print_info "Generating hardware-configuration.nix for this system..."
sudo nixos-generate-config --show-hardware-config > "$CONFIG_DIR/client/hardware-configuration.nix"
print_success "Hardware configuration generated"

# Generate variables.nix with user values
print_info "Generating variables.nix with user-specific values..."
AUTOLOGIN_VALUE="false"
if [ "$AUTOLOGIN" = "y" ]; then
    AUTOLOGIN_VALUE="true"
fi

# Get the script directory to find the template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/templates/variables.nix"

if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Generate variables.nix by substituting values in the template
sed -e "s/@USERNAME@/$USERNAME/g" \
    -e "s/@HOSTNAME@/$HOSTNAME/g" \
    -e "s/@TIMEZONE@/$TIMEZONE/g" \
    -e "s/@LOCALE@/$LOCALE/g" \
    -e "s/@KB_LAYOUT@/$KB_LAYOUT/g" \
    -e "s/@DESKTOP_ENV@/$DESKTOP_ENV/g" \
    -e "s/@AUTOLOGIN_VALUE@/$AUTOLOGIN_VALUE/g" \
    "$TEMPLATE_FILE" > "$CONFIG_DIR/client/variables.nix"
print_success "Configuration generated at $CONFIG_DIR/client/variables.nix"

# Test the flake configuration
print_info "Testing flake configuration..."
cd "$CONFIG_DIR"
if nix flake check 2>/dev/null; then
    print_success "Flake configuration is valid"
else
    print_warning "Flake check had warnings (this is usually okay)"
fi

# Apply configuration
print_info "Applying NixOS configuration..."
print_warning "This may take several minutes..."

if sudo nixos-rebuild switch --flake "$CONFIG_DIR#$CONFIGURATION"; then
    echo ""
    print_success "Installation complete!"
    print_success "Your NixOS system has been configured and will reboot momentarily."
    echo ""
    sleep 5
    reboot
else
    print_error "System rebuild failed. Please check the errors above."
    print_warning "Cleaning up failed installation..."
    sudo rm -rf "$CONFIG_DIR"
    print_info "Installation files removed. You can run the installer again."
    exit 1
fi
