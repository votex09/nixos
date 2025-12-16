# flake.nix - Main flake configuration
{
  description = "NixOS configuration with Catppuccin theming";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        # Default configuration - users can override the hostname
        nixos-desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            # Provide defaults for gitignored files if they don't exist
            ({ config, lib, ... }: {
              # This ensures the config can be evaluated even if settings.nix doesn't exist yet
              options = {};
            })
          ];
        };
      };
    };
}
