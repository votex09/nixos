#!/usr/bin/env bash

# This script reverts the system to its state before the installation script was run.
# Run this script with sudo.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

NIXOS_CONFIG_DIR="/home/nixosV"
ETC_CONFIG_BACKUP="${NIXOS_CONFIG_DIR}/tools/backup/configuration.nix.backup"

echo "--- Starting uninstallation process ---"

if [ ! -f "${ETC_CONFIG_BACKUP}" ]; then
    echo "Error: Backup configuration '${ETC_CONFIG_BACKUP}' not found."
    echo "Cannot automatically revert. Please restore '/etc/nixos/configuration.nix' manually."
    exit 1
fi

echo "--- Restoring original NixOS configuration ---"
mv "${ETC_CONFIG_BACKUP}" "/etc/nixos/configuration.nix"

echo "--- Applying the original configuration ---"
echo "This will rebuild your system. This may take a few minutes."
nixos-rebuild switch

echo "--- Cleaning up cloned repository ---"
if [ -d "${NIXOS_CONFIG_DIR}" ]; then
    rm -rf "${NIXOS_CONFIG_DIR}"
    echo "Removed ${NIXOS_CONFIG_DIR}"
fi

echo "--- Uninstallation complete! ---"
echo "The system has been reverted to its previous configuration."

shopt -s nullglob
BACKUP_DIRS=(/home/nixos.backup-*)
if [ ${#BACKUP_DIRS[@]} -gt 0 ]; then
    echo "Note: A backup of the original user configuration may exist at: ${BACKUP_DIRS[0]}"
fi