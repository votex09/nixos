{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${hostname}/configuration.nix
        ];
      };

      # Auto-discover all host directories
      hostDirs = builtins.attrNames (builtins.readDir ./hosts);
    in {
      nixosConfigurations = builtins.listToAttrs (
        map (host: { name = host; value = mkHost host; }) hostDirs
      );
    };
}
