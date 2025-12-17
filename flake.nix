{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      inherit (nixpkgs.lib) attrsets mapAttrs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Get list of available configurations
      configDirs = builtins.readDir ./configurations;
      getConfigs = attrsets.filterAttrs (name: type: type == "directory") configDirs;
    in
    {
      nixosConfigurations = mapAttrs (configName: _:
        let
          configDir = ./configurations/${configName};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self;
          };
          modules = [
            # Core system configuration
            {
              imports = [
                "${configDir}/config.nix"
              ];
              nixpkgs.overlays = [ ];
            }
          ];
        }
      ) getConfigs;
    };
}
