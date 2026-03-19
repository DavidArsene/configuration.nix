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
            mypkgs = inputs.mypkgs.packages;

            custom = {
              # Easy access to current arch
              inherit system;
              # Username to use everywhere
              myself = "david";
            };
          };

          modules =
            with inputs;
            with mylib.userModules;
            [
              common
              networking
              nix
              programs
              shell

              minimal.nixosModules.main
              minimal.nixosModules.systemPath
              nix-index-database.nixosModules.nix-index
            ];
        };

    in
    {
      nixosConfigurations = {
        phoenix = mkSystem "aarch64-linux" { hostName = "phoenix"; };

        legionix = mkSystem "x86_64-linux" {
          hostName = "legionix";

          hostModules =
            with inputs;
            with mylib.userModules;
            [
              desktop
              development
              gaming
              spicetify
              mypkgs.nixosModules.fprintd-fpc
              # mypkgs.nixosModules.ro-cei-pcsc
              minimal.nixosModules.kde
            ];
        };
      };

      #? Expose inputs for CLI commands to use same system versions.
      inherit inputs;
    };

  inputs = {
    #? wrapper for nixpkgs inputs to set allowUnfree
    nixpkgs.url = "git+https://gist.github.com/DavidArsene/67cade0eb2629d875712c6283ae1557d";
    #? Use nixpkgs.inputs.nixpkgs to set the source for the underlying nixpkgs

    # infrequent updates for entire system
    nixpkgs.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.inputs.nixpkgs.follows = "newpkgs/nixpkgs";

    #? clone the wrapper to use more instances of nixpkgs
    newpkgs.follows = "nixpkgs";
    # bleeding edge
    # newpkgs.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Has no dependencices
    minimal.url = "github:DavidArsene/minimal.nix";

    mypkgs.url = "github:DavidArsene/nur.nix";
    mypkgs.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:DavidArsene/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.follows = "nix-alien/nix-index-database";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.systems.follows = "kwin-blur/utils/systems";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

    nix-custom.url = "github:DavidArsene/nix";
    nix-custom.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    # TODO: add default.nix to nixpkgs wrapper for "import nixpkgs" support

    # FIXME: Almost works
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
  };
}
