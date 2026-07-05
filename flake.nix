{
  outputs =
    inputs:
    let
      mylib = (import ./mylib.nix) inputs;

      mkSystem =
        system:
        mylib.mkSystem {
          inherit system;

          specialArgs = {
            newpkgs = inputs.newpkgs.legacyPackages.${system};
            mypkgs = inputs.mypkgs.packages;
          };

          commonModules = with mylib.myModules; [
            common
            networking
            nix
            programs
            samba
            shell

            minimal.nixosModules.main
            minimal.nixosModules.systemPath
            nix-index-db.nixosModules.nix-index
          ];
        };

    in
    {
      nixosConfigurations = {
        phoenix = mkSystem "aarch64-linux" { hostName = "phoenix"; };

        legionix = mkSystem "x86_64-linux" {
          hostName = "legionix";

          hostModules = with mylib.myModules; [
            desktop
            development
            ios
            gaming
            # spicetify
            # mypkgs.nixosModules.fprintd-fpc
            # mypkgs.nixosModules.ro-cei-pcsc
            mypkgs.nixosModules.ministeam
            minimal.nixosModules.kde
          ];
        };

        spacex = mkSystem "x86_64-linux" {
          hostName = "spacex";
          hostModules = with mylib.myModules; [
            gaming
            matei
          ];
        };
      };

      devShell.x86_64-linux = import ./shell.nix {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        inherit (inputs) self;
      };

      #? Expose inputs for CLI commands to use same system versions.
      inherit inputs;
    };

  inputs = {
    #? wrapper for nixpkgs inputs to set allowUnfree
    newpkgs.url = "git+https://gist.github.com/DavidArsene/67cade0eb2629d875712c6283ae1557d";
    newpkgs.inputs.src.url = "github:NixOS/nixpkgs/nixos-unstable";
    #? Use nixpkgs.inputs.src to set the source for the underlying nixpkgs

    # infrequent updates for entire system
    # nixpkgs.url = "git+https://gist.github.com/DavidArsene/67cade0eb2629d875712c6283ae1557d";
    # nixpkgs.inputs.src.url = "github:NixOS/nixpkgs/da5ad661ba4e5ef59ba743f0d112cbc30e474f32";
    nixpkgs.follows = "newpkgs";

    minimal.url = "github:DavidArsene/minimal.nix";

    mypkgs.url = "github:DavidArsene/nur.nix";

    nix-custom.url = "github:DavidArsene/nix";

    home-manager.url = "github:nix-community/home-manager/master";

    nix-index-db.url = "github:nix-community/nix-index-database";

    spicetify.url = "github:Gerg-L/spicetify-nix";

    helium-flake.url = "github:oxcl/nix-flake-helium-browser";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";

    mypkgs.inputs.nixpkgs.follows = "nixpkgs";
    nix-custom.inputs.nixpkgs.follows = "nixpkgs/src";
    home-manager.inputs.nixpkgs.follows = "newpkgs";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.systems.follows = "kwin-blur/utils/systems";
    helium-flake.inputs.nixpkgs.follows = "nixpkgs";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

    # FIXME: Almost works
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
  };
}
