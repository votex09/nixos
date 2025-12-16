#!/usr/bin/env bash

# This script sets up the system to use a user-managed NixOS configuration.
# Run this script with sudo after a fresh NixOS installation.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
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

cat > /etc/nixos/configuration.nix <<EOF
# This file points to the real configuration in your home directory.
{
  imports = [ ${NIXOS_CONFIG_DIR}/configuration.nix ];
}
EOF

echo "--- Applying the new NixOS configuration ---"
nixos-rebuild switch

echo "--- Installation complete! ---"
echo "Your system is now managed by the configuration from your GitHub repository."