{
  outputs =
    inputs:
    let
      mylib = (import ./mylib.nix) inputs;
      newpkgsWrapped = inputs.minimal.wrapNixpkgs inputs.newpkgs;

      # TODO: IJ nix-idea search lib shiftshift action
      mkSystem =
        system:
        mylib.mkSystem {
          inherit system;

          specialArgs = {
            newpkgs = newpkgsWrapped.legacyPackages.${system};
            mypkgs = inputs.mypkgs.packages;

            custom = {
              # Easy access to current arch
              inherit system;
              # Username used everywhere
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

              minimal.nixosModules.default
              nix-index-database.nixosModules.nix-index
            ];
        };

    in
    {
      nixosConfigurations = {
        phoenix = mkSystem "aarch64-linux" { hostName = "phoenix"; };

        legionix = mkSystem "x86_64-linux" {
          hostName = "legionix";

          hostModules = with mylib.userModules; [
            desktop
            development
            gaming
            inputs.mypkgs.nixosModules.fprintd-fpc
            inputs.mypkgs.nixosModules.ro-cei-pcsc
          ];
        };
      };

      devShells.x86_64-linux =
        let
          _pkgs = newpkgsWrapped.legacyPackages.x86_64-linux;
        in
        {
          xconfig = _pkgs.mkShell {
            packages = with _pkgs; [

              linux_latest
              # (linux_latest.overrideAttrs (prev: {
              #   nativeBuildInputs = prev.nativeBuildInputs ++ [
              pkg-config
              qt6.qtbase
              #   ];
              #   dontWrapQtApps = true;
              # }))
            ];
          };
        };

      #? Expose inputs for CLI commands to use same system versions.
      inherit inputs;
    };

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/89c2b233"; # infrequent updates for entire system
    nixpkgs.follows = "newpkgs";

    newpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # bleeding edge
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
    # FIXME: Almost works

    # Has no dependencices, wraps any nixpkgs with wrapNixpkgs
    minimal.url = "github:DavidArsene/minimal.nix";

    # TODO: unfree with minimal
    mypkgs.url = "github:DavidArsene/mypkgs.nix";
    mypkgs.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:DavidArsene/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.follows = "nix-alien/nix-index-database";

    # zen.url = "github:0xc000022070/zen-browser-flake";
    # zen.inputs.nixpkgs.follows = "nixpkgs";
    # zen.inputs.home-manager.follows = "";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

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
