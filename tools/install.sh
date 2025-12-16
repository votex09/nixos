#!/usr/bin/env bash

# This script sets up the system to use a user-managed NixOS configuration.
# Run this script with sudo after a fresh NixOS installation.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Accept username and password as arguments (passed from launcher script)
USERNAME="${1:-}"
PASSWORD="${2:-}"

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

echo "--- Setting up user account ---"

# If credentials weren't passed as arguments, use defaults
if [ -z "$USERNAME" ]; then
    DEFAULT_USERNAME=$(grep "username = " "${NIXOS_CONFIG_DIR}/system/settings.nix" | sed 's/.*username = "\(.*\)";/\1/' | tr -d '[:space:]')
    USERNAME="$DEFAULT_USERNAME"
fi

echo "Creating user account: ${USERNAME}"

# Update settings.nix with the username
DEFAULT_USERNAME=$(grep "username = " "${NIXOS_CONFIG_DIR}/system/settings.nix" | sed 's/.*username = "\(.*\)";/\1/' | tr -d '[:space:]')
if [ "$USERNAME" != "$DEFAULT_USERNAME" ]; then
    sed -i "s/username = \".*\";/username = \"$USERNAME\";/" "${NIXOS_CONFIG_DIR}/system/settings.nix"
    echo "Updated username in settings.nix to: ${USERNAME}"
fi

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
nixos-rebuild switch

echo ""
echo "--- Installation complete! ---"
echo "Your system is now managed by the configuration from your GitHub repository."
echo ""
echo "The system will reboot in 5 seconds..."
echo "After reboot, log in with username: ${USERNAME}"
echo ""
echo "Press Ctrl+C to cancel automatic reboot."

sleep 5

echo "Rebooting now..."
reboot
