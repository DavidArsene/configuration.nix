{
  config,
  nix,
  nixpkgs,
  pkgs,
  ...
}:
let
  getdef = input: input.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  nix = {
    settings = {
      accept-flake-config = false;
      allow-import-from-derivation = false;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      build-dir = "/tmp";
      builders-use-substitutes = true;
      # ca-derivations = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "nix-command"
        "flakes"
        "local-overlay-store"
        "pipe-operators"
      ];
      flake-registry = "";
      fallback = false;
      # Includes files from fetch{url,zip}
      keep-derivations = false;
      # max-jobs = 0; # delegate all builds to server
      # pipe-operators = true;
      # show-trace = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
      trusted-substituters = [
        # NUR
        "https://nix-community.cachix.org"
        "https://shadowrz-nur.cachix.org"

        "https://install.determinate.systems"
        "https://nix-gaming.cachix.org"
      ];
      trusted-users = [ "@wheel" ];

      lazy-trees = true;
    };

    channel.enable = false;
    buildMachines = [
      {
        hostName = "creeper";
        system = "aarch64-linux";
        protocol = "ssh-ng";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        maxJobs = 1;
        speedFactor = 2;
        sshUser = config.custom.user;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
    distributedBuilds = true;

    # package = edge.lix;
    package = (getdef nix).overrideAttrs (old: {
      doCheck = false; # TODO: what causes it to build?
      doInstallCheck = false;
    });

    registry.nixpkgs.flake = nixpkgs;
  };

  programs = {
    nix-ld.enable = true;
    # nix-ld.libraries = [];

    nix-index-database.comma.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    # checkMeta = true;

    # Would replace the boring "-source" suffix
    # with the repo name and version.
    # Unfortunately causes mass rebuild (not even cached).
    # fetchedSourceNameDefault = "versioned";

    # Same with these:
    # doCheckByDefault = false;
    # enableParallelBuildingByDefault = true;
    # contentAddressedByDefault = true;
  };

  environment.etc."nixos" = {
    # TODO: change
    source = "/home/${config.custom.user}/nixconfig/";
    target = "nixos";
    mode = "symlink";
  };

  system.nixos.label = config.system.nixos.release;
  system.nixos.extraLSBReleaseArgs = {
    LSB_VERSION = "25.11 (Unstable)"; # TODO: fix
    DISTRIB_DESCRIPTION = "NixOS Enterprise ${config.system.nixos.release}";
  };

  environment.localBinInPath = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # TODO: Requires systemd in initrd, ruins my initrd-less boot plans
  # system.etc.overlay.enable = true;
  # system.etc.overlay.mutable = false;
}
