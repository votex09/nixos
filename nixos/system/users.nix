# /home/nixos/system/users.nix
#
# This file manages user accounts.

{ config, pkgs, ... }:

let
  settings = import ./settings.nix;
in
{
  users.users.${settings.username} = {
    isNormalUser = true;
    description = settings.fullName;
    extraGroups = [ "wheel" "networkmanager" ]; # 'wheel' grants sudo access.
    # You should set an initial password for the user by running `sudo passwd <username>`
    # after the first `nixos-rebuild switch`.
  };

  # You can add more users here if needed.
  # users.users.anotheruser = { ... };
}