{
  outputs =
    inputs:
    with inputs;
    let
      inherit (nixpkgs) lib;
      mkSystem =
        { hostName, system }:
        lib.nixosSystem {
          inherit system;

          specialArgs = inputs // {
            edge = import newpkgs {
              inherit system;
              # config = nixpkgs.config;
              config = {
                allowUnfree = true;
              };
            };
            # edge = newpkgs.legacyPackages.${system};
          };

          modules = [
            ./${hostName}
            modules/common.nix
            modules/nix.nix
            modules/programs.nix
            modules/shell.nix
            modules/minimal.nix

            nix-index-database.nixosModules.nix-index
            nur.modules.nixos.default
            {
              config.networking.hostName = hostName;

              # newpkgs.config = nixpkgs.config;

              options.custom = {
                user = lib.mkOption {
                  type = lib.types.str;
                  default = "david";
                };
              };
              options.UNUSED = lib.mkOption {
                type = lib.types.anything;
                description = "Alternative to comments.";
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        creeper = mkSystem {
          hostName = "creeper";
          system = "aarch64-linux";
        };

        legionix = mkSystem {
          hostName = "legionix";
          system = "x86_64-linux";
        };
      };

      # Standalone packages, _may_ be used standalone.
      packages = lib.filesystem.packagesFromDirectoryRecursive {
        inherit (nixpkgs) callPackage;
        directory = ./pkgs;
      };
    };

  # formatter =

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/9807714d"; # regular updates for entire system
    # nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    # newpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # bleeding edge
    newpkgs.follows = "nix-gaming/nixpkgs";

    nur.url = "github:nix-community/NUR";
    # Determinate Nix without the useless stuff
    nix.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-index-database.url = "github:nix-community/nix-index-database";
    # kwin-blur.url = "github:taj-ny/kwin-effects-forceblur";

    nix.inputs.nixpkgs.follows = "newpkgs";
    nix.inputs.flake-parts.follows = "nix-gaming/flake-parts";
    nix.inputs.nixpkgs-23-11.follows = "";
    nix.inputs.nixpkgs-regression.follows = "";
    nix.inputs.git-hooks-nix.follows = "";
    nur.inputs.nixpkgs.follows = "newpkgs";
    nur.inputs.flake-parts.follows = "nix-gaming/flake-parts";
    # nix-gaming.inputs.nixpkgs.follows = "newpkgs";
    nix-index-database.inputs.nixpkgs.follows = "newpkgs";
    # kwin-blur.inputs.nixpkgs.follows = "newpkgs";
  };
}
