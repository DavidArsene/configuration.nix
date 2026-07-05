inputs:
with inputs.nixpkgs.lib;

let
  this = rec {
    #? Used to install all packages, including ones
    #? that are normally skipped on upgrades due
    #? to being frequently rebuilt without changes.
    mkFreshOnly = pkg: mkIf (isEnvTrue "FRESH_INSTALL") pkg;

    marchNative =
      pkgs:
      let
        nativeStdenv = pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.fastStdenv;
      in

      pkg:

      # Ensure that pkg comes from this nixpkgs instance
      # assert pkg == pkgs.${pkg.name}; FIXME

      let
        nativePkg = pkg.override {
          stdenv = nativeStdenv;
          # buildPackages.stdenv = nativeStdenv;
        };
      in

      # Ensure stdenv was applied correctly
      # TODO: more checks / overrides
      # FIXME assert nativePkg.stdenv == nativeStdenv;

      builtins.trace "Building ${pkg.name} impurely for ${nativeStdenv.system}..." nativePkg;

    myModules =
      (
        builtins.readDir ./modules
        |> filterAttrs (name: _: hasSuffix ".nix" name)
        |> mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) ./modules/${name})
      )
      // inputs;

    #? Wrapper for everything (?) needed for a multi-host NixOS flake.
    #? Call this first with common customizations for all hosts,
    #? then call the resulting function with host-specific data.
    mkSystem =
      {
        system ? "x86_64-linux",
        specialArgs ? { },
        commonModules ? [ ],
      }:

      {
        hostName,
        hostModules ? [ ],
      }:

      #! Use the the custom nixosSystem from minimal.nix
      nixosSystem {
        inherit system;
        specialArgs = inputs // specialArgs // { mylib = this; };

        # excludes = modules.exclude or [ ];
        # includes = modules.include or [ ];

        # TODO: docs
        modules =
          commonModules
          ++ hostModules
          ++ [
            ./hosts/${hostName}
            {
              config = {
                networking.hostName = hostName;

                #? Use mkDefault since nixpkgs-flake.nix already creates registry
                #? entry for nixpkgs and ours would be the wrapper anyway.
                nix.registry = mapAttrs (k: v: mkDefault { flake = v; }) inputs;
              };

              options = {
                # NOTE: change this if you're not me
                users.myself = mkOption {
                  type = types.str;
                  default = "david";
                };
                comment = mkOption { type = types.anything; };
              };
            }
          ];
      };

    isEnvTrue =
      var:
      (builtins.getEnv var |> elem) [
        "1"
        "true"
        "yes"
      ];

    meld =
      inputs: builtins.foldl' (output: subflake: recursiveUpdate output (import subflake inputs)) { };

  };
in
this
