# Core system packages
# These are essential applications that should not be removed
# Edit with caution - removing these may break system functionality

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnome-console
  ];
}
