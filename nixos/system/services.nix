# /home/nixos/system/services.nix
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

  # Enable the CUPS printing system.
  services.printing.enable = true;

  # Enable sound with PipeWire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
  services.xserver.displayManager.gdm.enable = (settings.desktop == "gnome");
  services.xserver.desktopManager.gnome.enable = (settings.desktop == "gnome");

  services.xserver.displayManager.sddm.enable = (settings.desktop == "kde");
  services.xserver.desktopManager.plasma5.enable = (settings.desktop == "kde");

  services.xserver.displayManager.lightdm.enable = (settings.desktop == "xfce");
  services.xserver.desktopManager.xfce.enable = (settings.desktop == "xfce");
}