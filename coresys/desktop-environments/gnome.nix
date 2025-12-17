{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gedit
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-console
  ];

  services.gnome.gnome-settings-daemon.enable = true;
}
