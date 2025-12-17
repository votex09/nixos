{ config, pkgs, self, variables ? {}, ... }:

let
  de = variables.desktopEnvironment or "gnome";
in

{
  # Desktop Environment selection
  desktopEnvironments = {
    gnome = {
      enable = de == "gnome";
      packages = with pkgs; [
        gnome-tweaks
        gnome-console
      ];
      config = {
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
        services.gnome.gnome-settings-daemon.enable = true;
      };
    };

    kde = {
      enable = de == "kde";
      packages = with pkgs; [
        kdePackages.plasma-desktop
        kdePackages.kdeplasma-addons
        kdePackages.konsole
        kdePackages.dolphin
        kdePackages.kate
      ];
      config = {
        services.xserver = {
          enable = true;
          desktopManager.plasma5.enable = true;
          displayManager.sddm.enable = true;
        };
      };
    };

    cosmic = {
      enable = de == "cosmic";
      packages = with pkgs; [
        cosmic-desktop
      ];
      config = {
        services.xserver = {
          enable = true;
        };
      };
    };
  };

  # Common packages across all DEs
  environment.systemPackages = with pkgs; [
    # Utilities
    curl
    wget
    git
    vim
    htop
    neofetch
    file-roller
    evince

    # Browser
    firefox
  ] ++ (
    if config.desktopEnvironments.gnome.enable then config.desktopEnvironments.gnome.packages
    else if config.desktopEnvironments.kde.enable then config.desktopEnvironments.kde.packages
    else if config.desktopEnvironments.cosmic.enable then config.desktopEnvironments.cosmic.packages
    else [ ]
  );

  # Apply the selected DE configuration
  imports = [
    (
      if de == "gnome" then
        (import "${self}/coresys/desktop-environments/gnome.nix")
      else if de == "kde" then
        (import "${self}/coresys/desktop-environments/kde.nix")
      else if de == "cosmic" then
        (import "${self}/coresys/desktop-environments/cosmic.nix")
      else
        (import "${self}/coresys/desktop-environments/gnome.nix")  # Default to GNOME
    )
  ];
}
