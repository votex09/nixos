{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-desktop
    kdePackages.kdeplasma-addons
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.kwrite
  ];
}
