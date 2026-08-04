{
  outputs =
    inputs:
    let
      mylib = (import ./mylib.nix) inputs;
    in
    {
      nixosConfigurations = mylib.genSystems {
        hosts = {
          legionix = "x86_64-linux";
          phoenix = "aarch64-linux";
          spacex = "x86_64-linux";
        };

        specialArgs = system: {
          newpkgs = inputs.newpkgs.legacyPackages.${system};
          mypkgs = inputs.mypkgs.packages;
        };

        commonModules =
          mods: with mods; [
            common
            networking
            nix
            programs
            shell

            minimal.nixosModules.main
            minimal.nixosModules.systemPath
            nix-index-db.nixosModules.nix-index
          ];
      };

      devShell.x86_64-linux = import ./shell.nix {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        inherit (inputs) self;
      };

      #? Expose inputs for CLI commands to use same system versions.
      inherit inputs;

      #? Ugly hack
      idea =
        inputs.self.nixosConfigurations."legionix".config.environment.systemPackages
        |> inputs.nixpkgs.lib.findFirst (pkg: pkg.name == "jetbrains-idea-2026.2") null;
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

    nix-index-db.url = "github:nix-community/nix-index-database";

    spicetify.url = "github:Gerg-L/spicetify-nix";

    helium.url = "github:jcdickinson/helium-wv";

    kwin-blur.url = "github:xarblu/kwin-effects-better-blur-dx";

    mypkgs.inputs.nixpkgs.follows = "nixpkgs";
    nix-custom.inputs.nixpkgs.follows = "nixpkgs/src";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";
    spicetify.inputs.systems.follows = "kwin-blur/utils/systems";
    helium.inputs.nixpkgs.follows = "nixpkgs/src";
    helium.inputs.utils.follows = "kwin-blur/utils";
    kwin-blur.inputs.nixpkgs.follows = "nixpkgs";

    # FIXME: Almost works
    # https://github.com/NixOS/nixpkgs/archive/nixos-unstable@%7B2025-11-11%7D.tar.gz
  };
}
