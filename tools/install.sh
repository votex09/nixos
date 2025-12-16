#!/usr/bin/env bash

# This script sets up the system to use a user-managed NixOS configuration.
# Run this script with sudo after a fresh NixOS installation.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Accept user information as arguments (passed from launcher script)
USERNAME="${1:-}"
PASSWORD="${2:-}"
FULLNAME="${3:-}"
HOSTNAME="${4:-}"

# Check if git is available, if not install it temporarily
if ! command -v git &> /dev/null; then
    echo "--- Git not found, installing temporarily ---"
    nix-env -iA nixos.git
fi

REPO_URL="https://github.com/votex09/nixos.git"
NIXOS_CONFIG_DIR="/home/nixosV" # The directory where the repo will be cloned.

echo "--- Backing up existing configuration directory (if any) ---"
if [ -d "${NIXOS_CONFIG_DIR}" ]; then
    mv "${NIXOS_CONFIG_DIR}" "${NIXOS_CONFIG_DIR}.backup-$(date --iso-8601=seconds)"
    echo "Backed up existing ${NIXOS_CONFIG_DIR}"
fi

echo "--- Cloning NixOS configuration from ${REPO_URL} ---"
git clone "${REPO_URL}" "${NIXOS_CONFIG_DIR}"

echo "--- Creating backup directory ---"
mkdir -p "${NIXOS_CONFIG_DIR}/tools/backup"

echo "--- Backing up and copying hardware configuration ---"
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    cp /etc/nixos/hardware-configuration.nix "${NIXOS_CONFIG_DIR}/system/hardware-configuration.nix"
    echo "Hardware configuration copied to ${NIXOS_CONFIG_DIR}/system/hardware-configuration.nix"
else
    echo "Warning: /etc/nixos/hardware-configuration.nix not found. A placeholder will be used."
fi

echo "--- Creating new main configuration file ---"
if [ -f "/etc/nixos/configuration.nix" ]; then
    mv "/etc/nixos/configuration.nix" "${NIXOS_CONFIG_DIR}/tools/backup/configuration.nix.backup"
fi

echo "--- Detecting system settings ---"

# Detect current timezone
if [ -L /etc/localtime ]; then
    CURRENT_TIMEZONE=$(readlink /etc/localtime | sed 's|/usr/share/zoneinfo/||')
    echo "Detected timezone: ${CURRENT_TIMEZONE}"
else
    CURRENT_TIMEZONE="UTC"
    echo "Could not detect timezone, using: ${CURRENT_TIMEZONE}"
fi

# Detect current locale
if [ -f /etc/locale.conf ]; then
    CURRENT_LOCALE=$(grep "^LANG=" /etc/locale.conf | cut -d= -f2)
    echo "Detected locale: ${CURRENT_LOCALE}"
else
    CURRENT_LOCALE="en_US.UTF-8"
    echo "Could not detect locale, using: ${CURRENT_LOCALE}"
fi

# Use the hostname provided by the user
echo "Setting hostname: ${HOSTNAME}"

echo ""
echo "--- Setting up user account ---"

# If credentials weren't passed as arguments, use defaults
if [ -z "$USERNAME" ]; then
    DEFAULT_USERNAME=$(grep "username = " "${NIXOS_CONFIG_DIR}/system/settings.nix" | sed 's/.*username = "\(.*\)";/\1/' | tr -d '[:space:]')
    USERNAME="$DEFAULT_USERNAME"
fi

echo "Creating user account: ${USERNAME}"
echo "Full name: ${FULLNAME}"

# Update settings.nix with detected system settings and user information
sed -i "s|timezone = \".*\";|timezone = \"${CURRENT_TIMEZONE}\";|" "${NIXOS_CONFIG_DIR}/system/settings.nix"
sed -i "s|locale = \".*\";|locale = \"${CURRENT_LOCALE}\";|" "${NIXOS_CONFIG_DIR}/system/settings.nix"
sed -i "s|hostname = \".*\";|hostname = \"${HOSTNAME}\";|" "${NIXOS_CONFIG_DIR}/system/settings.nix"
sed -i "s/username = \".*\";/username = \"$USERNAME\";/" "${NIXOS_CONFIG_DIR}/system/settings.nix"
sed -i "s/fullName = \".*\";/fullName = \"$FULLNAME\";/" "${NIXOS_CONFIG_DIR}/system/settings.nix"
echo "Updated system and user settings in settings.nix"

# Create the user temporarily if it doesn't exist yet
if ! id "${USERNAME}" &>/dev/null; then
    echo "Creating temporary user account..."
    useradd -m -s /bin/bash "${USERNAME}" || {
        echo "Error: Failed to create user ${USERNAME}"
        exit 1
    }
fi

# Set the password
if [ -n "$PASSWORD" ]; then
    echo "Setting password for ${USERNAME}..."
    echo "${USERNAME}:${PASSWORD}" | chpasswd || {
        echo "Error: Failed to set password"
        exit 1
    }
    echo "Password set successfully!"
else
    echo "Error: No password provided"
    exit 1
fi

echo ""
echo "--- Creating new main configuration file ---"
cat > /etc/nixos/configuration.nix <<EOF
# This file points to the real configuration in your home directory.
{
  imports = [ ${NIXOS_CONFIG_DIR}/configuration.nix ];
}
EOF

echo "--- Applying the new NixOS configuration ---"
echo "Note: The screen may go black when the display manager switches."
echo "The system will automatically reboot after the configuration is applied."
echo ""

nixos-rebuild switch

# After nixos-rebuild switch, the display manager has changed and screen is black
# Reboot immediately without any messages (they won't be visible anyway)
systemctl reboot
