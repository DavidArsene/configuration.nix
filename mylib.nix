{ nixpkgs, minimal, ... }@inputs:
let
  lib = nixpkgs.lib;
  nixpkgsFlake = minimal.wrapNixpkgs nixpkgs;

  this = rec {
    #? Used to install all packages, including ones
    #? that are normally skipped on upgrades due
    #? to being frequently rebuilt without changes.
    mkFreshOnly = pkg: lib.mkIf (isEnvTrue "FRESH_INSTALL") pkg;

    optimizedBuild =
      pkgs: pkg:
      pkg.overrideAttrs rec {
        stdenv = pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.fastStdenv;
        buildPackages.stdenv = stdenv;
      };

    userModules =
      with lib;
      builtins.readDir ./modules
      |> attrNames
      |> filter (hasSuffix ".nix")
      |> map (filename: {
        name = removeSuffix ".nix" filename;
        value = ./modules/${filename};
      })
      |> listToAttrs;

    #? Wrapper for everything (?) needed for a multi-host NixOS flake.
    #? Call this first with common customizations for all hosts,
    #? then call the resulting function with host-specific data.
    mkSystem =
      {
        system ? "x86_64-linux",
        specialArgs ? { },
        modules ? [ ],
      }:

      {
        hostName,
        hostModules ? [ ],
      }:

      #! Use the the custom nixosSystem from minimal.nix
      nixpkgsFlake.nixosSystem {
        inherit system;
        specialArgs = inputs // specialArgs // { mylib = this; };

        # excludes = modules.exclude or [ ];
        # includes = modules.include or [ ];

        # TODO: docs
        modules =
          modules
          ++ hostModules
          ++ [
            ./hosts/${hostName}
            { config.networking.hostName = hostName; }
          ];
      }
      |> builtins.trace "Building NixOS system for ${hostName}...";

    isEnvTrue =
      var:
      (builtins.getEnv var |> lib.elem) [
        "1"
        "true"
        "yes"
      ];

    meld =
      inputs: builtins.foldl' (output: subflake: lib.recursiveUpdate output (import subflake inputs)) { };

  };
in
this
