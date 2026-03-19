inputs:
let
  lib = inputs.nixpkgs.lib;

  this = rec {
    #? Used to install all packages, including ones
    #? that are normally skipped on upgrades due
    #? to being frequently rebuilt without changes.
    mkFreshOnly = pkg: lib.mkIf (isEnvTrue "FRESH_INSTALL") pkg;

    marchNative =
      pkgs: pkg:
      pkg.overrideAttrs rec {
        stdenv = pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.fastStdenv;
        buildPackages.stdenv = stdenv;
      };

    userModules =
      with lib;
      builtins.readDir ./modules
      |> filterAttrs (name: _: hasSuffix ".nix" name)
      |> mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) (./modules/${name}));

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
      lib.nixosSystem {
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
            {
              config.networking.hostName = hostName;
              config.nix.registry = lib.mapAttrs (k: v: {
                to = {
                  type = "path";
                  path = v;
                };
              }) inputs;
            }
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
