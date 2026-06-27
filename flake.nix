{
  outputs =
    inputs:
    let
      mylib = (import ./mylib.nix) inputs;

      # TODO: IJ nix-idea search lib shiftshift action
      mkSystem =
        system:
        mylib.mkSystem {
          inherit system;

          specialArgs = {
            newpkgs = inputs.newpkgs.legacyPackages.${system};
            # oldpkgs = inputs.oldpkgs.legacyPackages.${system};
            mypkgs = inputs.mypkgs.packages;

            custom = {
              # Easy access to current arch
              inherit system;
              # Username to use everywhere
              myself = "david";
            };
          };

          modules = with mylib.myModules; [
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
            mypkgs.nixosModules.fprintd-fpc
            # mypkgs.nixosModules.ro-cei-pcsc
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

      devShell.x86_64-linux = import ./shell.nix { pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; };

      #? Expose inputs for CLI commands to use same system versions.
      inherit inputs;
    };

  inputs = {
    #? wrapper for nixpkgs inputs to set allowUnfree
    # nixpkgs.url = "git+https://gist.github.com/DavidArsene/67cade0eb2629d875712c6283ae1557d";
    #? Use nixpkgs.inputs.src to set the source for the underlying nixpkgs

    # infrequent updates for entire system
    # nixpkgs.inputs.src.url = "github:NixOS/nixpkgs/da5ad661ba4e5ef59ba743f0d112cbc30e474f32";
    nixpkgs.follows = "newpkgs";

    # bleeding edge
    newpkgs.url = "git+https://gist.github.com/DavidArsene/67cade0eb2629d875712c6283ae1557d";
    # newpkgs.inputs.src.url = "github:NixOS/nixpkgs/nixos-unstable";
    newpkgs.inputs.src.url = "github:NixOS/nixpkgs/89ccddc4c5565410c9c5c81eef193c93e6eda92a";

    # Has no dependencices
    minimal.url = "github:DavidArsene/minimal.nix";

    mypkgs.url = "github:DavidArsene/nur.nix";
    mypkgs.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-db.url = "github:nix-community/nix-index-database";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.systems.follows = "kwin-blur/utils/systems";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

    nix-custom.url = "github:DavidArsene/nix";
    nix-custom.inputs.nixpkgs.follows = "nixpkgs/src";

    helium-flake.url = "github:oxcl/nix-flake-helium-browser";
    helium-flake.inputs.nixpkgs.follows = "nixpkgs";

    # FIXME: Almost works
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
  };
}
