#!/usr/bin/env bash

# This script updates your local NixOS configuration from the GitHub repository.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

NIXOS_CONFIG_DIR="/home/nixosV"

if [ ! -d "${NIXOS_CONFIG_DIR}/.git" ]; then
    echo "Error: ${NIXOS_CONFIG_DIR} is not a git repository."
    echo "This script can only update configurations installed via the installer."
    exit 1
fi

echo "--- Updating NixOS configuration from GitHub ---"
cd "${NIXOS_CONFIG_DIR}"

# Stash any local changes to avoid conflicts
if ! git diff-index --quiet HEAD --; then
    echo "You have local changes. Stashing them..."
    git stash
    STASHED=1
else
    STASHED=0
fi

# Pull the latest changes
git pull origin main

# Pop the stash if we stashed changes
if [ $STASHED -eq 1 ]; then
    echo "Applying your local changes back..."
    git stash pop || {
        echo "Warning: There were conflicts when applying your local changes."
        echo "Please resolve them manually."
    }
fi

echo ""
echo "--- Rebuilding system with updated configuration ---"
nixos-rebuild switch

echo ""
echo "--- Update complete! ---"
echo "Your system has been updated with the latest configuration from GitHub."
