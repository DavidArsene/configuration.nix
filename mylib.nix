{ nixpkgs, minimal, ... }@inputs:
let
  lib = nixpkgs.lib;
  nixpkgsFlake = minimal.wrapNixpkgs nixpkgs;
in
rec {

  # Used to install all packages, including ones
  # that are normally skipped on upgrades due
  # to being frequently rebuilt without changes.
  mkFreshOnly = pkg: lib.mkIf (isEnvTrue "FRESH_INSTALL") pkg;

  allAvailableModules =
    with lib;
    builtins.readDir ./modules
    |> attrNames
    |> filter (hasSuffix ".nix")
    |> map (filename: {
      name = removeSuffix ".nix" filename;
      value = ./modules/${filename};
    })
    |> listToAttrs;

  # Wrapper for everything (?) needed for a multi-host NixOS flake.
  # Call this first with common customizations for all hosts,
  # then call the resulting function with host-specific data.
  mkSystem =
    {
      specialArgs,
      modules ? {
        external = [ ];
        common = [ ];
        extra = { };
        include = [ ];
        exclude = [ ];
      },
    }:

    {
      hostName,
      system,
      hostModules ? [ ],
    }:

    # ! Use custom nixosSystem which makes up a big part of minimal.nix
    nixpkgsFlake.nixosSystem {
      inherit system;
      specialArgs = inputs // (specialArgs system);

      # excludes = modules.exclude or [ ];
      # includes = modules.include or [ ];

      # TODO: docs
      modules =
        modules.external or [ ]
        ++ modules.common or [ ]
        ++ hostModules
        ++ [
          ./hosts/${hostName}
          modules.extra or { }

          { config.networking.hostName = hostName; }
        ];
    };

  isEnvTrue =
    var:
    (builtins.getEnv var |> lib.elem) [
      "1"
      "true"
      "yes"
    ];

  meld =
    inputs: builtins.foldl' (output: subflake: lib.recursiveUpdate output (import subflake inputs)) { };

}
