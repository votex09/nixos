{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Desktop environment
    gnome-tweaks
    gnome-console

    # Utilities
    file-roller
    gedit
    evince

    # Media
    gnome-photos
    totem

    # Default applications
    firefox
  ];

  # GNOME Settings Daemon
  services.gnome.gnome-settings-daemon.enable = true;
}
