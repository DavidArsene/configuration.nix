inputs:
with inputs.nixpkgs.lib;

let
  this = rec {

    marchNative =
      pkgs:
      let
        nativeStdenv = pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.fastStdenv;
      in

      pkg:
      # Ensure package can actually be rebuilt by changing stdenv
      assert pkg.override.__functionArgs ? stdenv;

      let
        nativePkg = pkg.override {
          stdenv = nativeStdenv;
          # buildPackages.stdenv = nativeStdenv; TODO:
        };
      in

      # Ensure stdenv was applied correctly
      # TODO: more checks / overrides
      assert nativePkg.stdenv.drvPath == nativeStdenv.drvPath;

      builtins.trace "Building optimized ${pkg.name} impurely..." nativePkg;

    #
    myModules =
      builtins.readDir ./modules
      |> filterAttrs (name: _: hasSuffix ".nix" name)
      |> mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) ./modules/${name})
      |> (_: _ // inputs);

    #?
    #? Wrapper for everything (?) needed for a multi-host NixOS flake.
    #? Call this first with common customizations for all hosts, then
    #? call the resulting function with an attrSet of hostName -> system.
    genSystems =
      {
        hosts ? { },
        specialArgs ? system: { },
        commonModules ? mods: [ ],
      }:

      mapAttrs (
        hostName: system:

        #! Use the the custom nixosSystem from minimal.nix
        nixosSystem {
          inherit system;
          specialArgs = inputs // (specialArgs system) // { mylib = this; };

          modules = (commonModules myModules) ++ [
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
        }
      ) hosts;

    #? Used to install all packages, including ones
    #? that are normally skipped on upgrades due
    #? to being frequently rebuilt without changes.
    # TODO: flakey-profile?
    mkFreshOnly = pkg: mkIf (builtins.getEnv "FRESH_INSTALL" == "1") pkg;

    meld =
      inputs: builtins.foldl' (output: subflake: recursiveUpdate output (import subflake inputs)) { };

  };
in
this
