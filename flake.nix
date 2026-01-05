{
  outputs =
    { minimal, ... }@inputs:
    let
      mylib = (import ./mylib.nix) inputs;
      myModules = mylib.allAvailableModules;

      newpkgsWrapped = minimal.wrapNixpkgs inputs.newpkgs;
      mypkgs = inputs.mypkgs.packages;

      # TODO: IJ nix-idea search lib shiftshift action
      mkSystem = mylib.mkSystem {

        specialArgs = system: {
          newpkgs = newpkgsWrapped.legacyPackages.${system};
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
            inputs.mypkgs.nixosModules.fprintd-fpc
            inputs.mypkgs.nixosModules.ro-mai-ca-chain

            nix-index-database.nixosModules.nix-index
            # nur.nixosModules.default
          ];

          common = with myModules; [
            common
            networking
            nix
            programs
            shell
          ];

          extra = {
            config.nixos.minify.everything = true;
          };
        };
      };

    in
    {
      nixosConfigurations = {
        phoenix = mkSystem {
          hostName = "phoenix";
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
    nixpkgs.url = "github:NixOS/nixpkgs/89c2b233"; # infrequent updates for entire system
    # nixpkgs.follows = "newpkgs";

    newpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # bleeding edge
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
    # FIXME: Almost works

    # Has no dependencices, wrap any nixpkgs with wrapNixpkgs
    minimal.url = "github:DavidArsene/minimal.nix";

    # TODO: unfree with minimal
    mypkgs.url = "github:DavidArsene/mypkgs.nix";
    mypkgs.inputs.nixpkgs.follows = "nixpkgs";

    # nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "newpkgs";

    # zen.url = "github:0xc000022070/zen-browser-flake";
    # zen.inputs.nixpkgs.follows = "nixpkgs";
    # zen.inputs.home-manager.follows = "";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

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
