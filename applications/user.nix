# User-defined custom packages (optional)
# Add your personal applications here
# These packages are optional and can be safely removed or modified

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Add your custom packages below:
    firefox
    gnome-tweaks
  ];
}
