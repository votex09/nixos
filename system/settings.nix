# /home/nixosV/system/settings.nix
#
# This file contains easily modifiable settings for your system.

{
  # --- General System Settings ---
  hostname = "nixos-desktop"; # Sets the machine's network name.
  timezone = "America/Chicago"; # e.g., "Europe/Berlin", "America/Los_Angeles"
  locale = "en_US.UTF-8";

  # --- User-specific Settings ---
  username = "nixos";
  fullName = "NixOS User";
  email = "nixos@example.com";

  # --- Desktop Environment ---
  # Valid options include "gnome", "kde", "xfce", or "none".
  # If you choose "none", you'll get a command-line only system.
  desktop = "gnome";
}