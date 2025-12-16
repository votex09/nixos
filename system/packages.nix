# /home/nixosV/system/packages.nix
#
# This file lists the packages to be installed system-wide.

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Essentials ---
    vim
    git
    wget
    curl

    # --- GNOME Extensions & Tools ---
    gnome-tweaks
    gnomeExtensions.appindicator

    # --- Themes ---
    catppuccin-gtk
    catppuccin-cursors.mochaDark
    papirus-icon-theme

    # --- Add your desired packages here ---
    firefox
    # vlc
    # gimp

    # --- Custom update script ---
    (pkgs.writeScriptBin "update" ''
      #!/usr/bin/env bash
      set -euo pipefail

      NIXOS_CONFIG_DIR="/home/nixosV"

      if [ ! -d "$NIXOS_CONFIG_DIR/.git" ]; then
        echo "Error: $NIXOS_CONFIG_DIR is not a git repository."
        echo "This command only works with configurations installed via the installer."
        exit 1
      fi

      # If not running as root, re-execute with sudo
      if [ "$EUID" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi

      echo "--- Updating NixOS configuration from GitHub ---"
      cd "$NIXOS_CONFIG_DIR"

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
    '')
  ];
}