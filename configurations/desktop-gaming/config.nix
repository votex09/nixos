{ config, pkgs, self, variables ? {}, ... }:

{
  imports = [
    ../client/hardware-configuration.nix
    ../coresys/applications.nix
  ];

  # System settings from variables.nix
  networking.hostName = variables.hostname or "nixos";
  time.timeZone = variables.timezone or "UTC";
  i18n.defaultLocale = variables.locale or "en_US.UTF-8";
  console.keyMap = variables.keyboardLayout or "us";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;

  # User configuration
  users.users.${variables.username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    createHome = true;
    shell = pkgs.bash;
  };

  # Auto-login if enabled
  services.displayManager.autoLogin = {
    enable = variables.autoLogin;
    user = if variables.autoLogin then variables.username else null;
  };

  # Prevent auto-logout
  systemd.services."autologin@" = {
    enable = variables.autoLogin;
  };

  # System state version (do not change)
  system.stateVersion = "24.11";
}
