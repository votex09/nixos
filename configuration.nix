# /home/nixosV/configuration.nix
#
# This is the main NixOS configuration file.
# It imports other modules to keep things organized.

{ config, pkgs, ... }:

let
  # Import user-specific settings from settings.nix
  settings = import ./system/settings.nix;
in
{
  imports =
    [
      # Hardware-specific configuration.
      ./system/hardware-configuration.nix

      # User and package management.
      ./system/users.nix
      ./system/packages.nix

      # System services.
      ./system/services.nix
    ];

  # Use settings from settings.nix
  networking.hostName = settings.hostname;
  time.timeZone = settings.timezone;
  i18n.defaultLocale = settings.locale;

  # Boot loader configuration
  # Use systemd-boot for UEFI systems (most modern hardware)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For BIOS/Legacy systems, comment out the above and uncomment below:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda"; # Change to your disk

  # System-wide state version.
  system.stateVersion = "25.11";
}