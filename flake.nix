{
  outputs =
    { minimal, ... }@inputs:
    let
      mylib = (import ./mylib.nix) inputs;
      myModules = mylib.allAvailableModules;

      # nixpkgsWrapped = minimal.wrapNixpkgs inputs.nixpkgs;
      newpkgsWrapped = minimal.wrapNixpkgs inputs.newpkgs;

      mypkgs =
        (
          inputs.mypkgs
          // {
            inputs.nixpkgs = {
              legacyPackages = throw 1;
            };
          }
        ).packages;

      # TODO: IJ nix-idea search lib shiftshift action
      mkSystem = mylib.mkSystem {

        specialArgs = system: {
          edge = newpkgsWrapped.legacyPackages.${system};

          inherit mylib mypkgs; # TODO: move to mylib boiler (and custom.system)

          custom = {
            # Easy access to current arch
            inherit system;
            # Username used everywhere
            myself = "david";
          };
        };

        modules = {

          external = with inputs; [
            minimal.nixosModules.default
            nix-index-database.nixosModules.nix-index
            # nur.nixosModules.default
          ];

          common = with myModules; [
            common
            nix
            programs
            shell

            modern
          ];

          extra = {
            config.nixos.minify.everything = true;
          };

        };

      };

      #
      #
      #
      #
      #TODO: STC_DEBUG=1
      #STC_DISPLAY_ALL_UNITS=1.
      #W
      #
      #

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

          hostModules = with myModules; [
            desktop
            development
            gaming
          ];
        };
      };
    };

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/7df7ff7d"; # regular updates for entire system
    nixpkgs.follows = "newpkgs";

    newpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # bleeding edge
    # newpkgs.url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz";

    # Has no dependencices, used to wrap other nixpkgs
    minimal.url = "github:DavidArsene/minimal.nix";

    # TODO: unfree with minimal
    mypkgs.url = "/home/david/.nix/mypkgs.nix";
    mypkgs.inputs.nixpkgs.follows = "newpkgs";

    # nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "newpkgs";

    zen.url = "github:0xc000022070/zen-browser-flake";
    zen.inputs.nixpkgs.follows = "newpkgs";
    zen.inputs.home-manager.follows = "";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "newpkgs";

    # nix-detsys.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
    # nix-detsys.inputs.nixpkgs.follows = "newpkgs";

    # who even needs determinate-nixd
    # nix-detsys.inputs = {
    #   flake-parts.follows = "nur/flake-parts";
    #   nixpkgs-23-11.follows = "";
    #   nixpkgs-regression.follows = "";
    #   git-hooks-nix.follows = "";
    # };
  };
}
