# /home/nixosV/system/services.nix
#
# This file is for enabling and configuring system services.

{ config, pkgs, ... }:

let
  settings = import ./settings.nix;
in
{
  # Enable the graphical session.
  # This enables the X server, which is required for XWayland compatibility
  # to run X11 applications on Wayland.
  services.xserver.enable = true;

  # Enable NetworkManager for network connectivity
  networking.networkmanager.enable = true;

  # Enable the CUPS printing system.
  services.printing.enable = true;

  # Enable sound with PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Desktop Environment ---
  # Enable the desktop environment specified in settings.nix.
  # GDM (for GNOME) and SDDM (for KDE) will default to a Wayland session.
  services.displayManager.gdm.enable = (settings.desktop == "gnome");
  services.desktopManager.gnome.enable = (settings.desktop == "gnome");

  # Exclude some GNOME apps to reduce bloat
  environment.gnome.excludePackages = (if settings.desktop == "gnome" then (with pkgs; [
    gnome-tour
    epiphany # web browser
    geary # email client
  ]) else []);

  # Configure GNOME theme settings
  programs.dconf.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
    XCURSOR_SIZE = "24";
    GTK_THEME = "catppuccin-mocha-mauve-standard+default";
  };

  # Create a systemd user service to apply GNOME theme settings on login
  systemd.user.services.apply-gnome-theme = {
    description = "Apply Catppuccin theme to GNOME";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    script = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'catppuccin-mocha-mauve-standard+default'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'catppuccin-mocha-dark-cursors'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-size 24
    '';
  };

  services.displayManager.sddm.enable = (settings.desktop == "kde");
  services.desktopManager.plasma6.enable = (settings.desktop == "kde");

  services.displayManager.lightdm.enable = (settings.desktop == "xfce");
  services.desktopManager.xfce.enable = (settings.desktop == "xfce");

  # Enable dbus (required for display managers)
  services.dbus.enable = true;
}