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
  ];
}