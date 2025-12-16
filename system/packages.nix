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
    git

    # --- Add your desired packages here ---
    firefox
    # vlc
    # gimp
  ];
}