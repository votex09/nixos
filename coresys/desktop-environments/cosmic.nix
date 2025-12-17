{ pkgs, ... }:

{
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-desktop
  ];

  # Cosmic uses its own display manager and session
  services.displayManager.cosmic-greeter.enable = true;
}
