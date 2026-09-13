{
  config,
  pkgs,
  nix-custom,
  self,
  ...
}:
{
  nix = {
    settings = {
      accept-flake-config = false;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      flake-registry = ""; # "global" registry, not used by CLIs
      fallback = false;
      keep-derivations = false; # Includes files from fetch{url,zip}
      # max-jobs = 0; # delegate all builds to server
      sandbox = "relaxed";
      # show-trace = true;
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://helium-wv.cachix.org"
      ];
      trusted-users = [ "@wheel" ];
      warn-dirty = false;
    }

    # Modernize Nix
    // {
      auto-allocate-uids = true;
      # ca-derivations = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "configurable-impure-env" # TODO tryme
        "nix-command"
        "flakes"
        "local-overlay-store"
        # "parallel-eval" # meeeeeeeeeeeeeeeeeee to
        "pipe-operators"
      ];
      use-xdg-base-directories = true;
    };

    channel.enable = false;
    # Not worth it. Works, but all programs accessing nix
    # (like fastfetch or nixd) end up requiring sudo.
    # NOTE: move to minify? (after making it usable)
    # daemon.enable = false;

    # package = pkgs.nixVersions.latest;
    package = nix-custom.packages.${pkgs.stdenv.system}.default;
    # Modernizing ends here.

    buildMachines = [
      {
        hostName = "phoenix";
        system = "aarch64-linux";
        protocol = "ssh-ng";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        maxJobs = 1;
        speedFactor = 2;
        sshUser = config.users.myself;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
    distributedBuilds = true;
  };

  # TODO: nixpkgs.config.handleEvalIssue can handle unfree/broken/etc errors check it aut

  environment.systemPackages = with pkgs; [
    nix-derivation
    # nix-fast-build
    # nix-forecast
    ## TODO nix-inspect
    # nix-locate
    nix-output-monitor
    nix-tree
    # nix-update TODO:
    dix
    manix
    statix
    # lon
  ];

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # TODO: comprehensive
        gtk3
        libGL
        libx11
        qt6Packages.qtbase
      ];
    };
    nix-index-database.comma.enable = true;
  };

  environment.etc = {
    #? A link to the version of the config used to build this system.
    "source".source = self;
  };

  system.nixos.label = config.system.nixos.release;

  system.etc.overlay.enable = true;
  # system.etc.overlay.mutable = false; # FIXME:
  system.nixos-init.enable = true;
  boot.initrd.systemd.emergencyAccess = config.users.users.${config.users.myself}.hashedPassword;
  # boot.initrd.clevis.enable = true;
  boot.initrd.checkJournalingFS = true;
  services.userborn.enable = true;
  services.userborn.importLegacyState = false;

  comment.nixpkgs.config = {
    #? Would replace the boring "-source" suffix
    #? with the repo name and version.
    #? Unfortunately causes mass rebuild (nothing cached).
    #* NOTE: CppNix hardcodes "source" in a few places.
    # fetchedSourceNameDefault = "versioned";

    #? Same with these:
    # doCheckByDefault = false;
    # enableParallelBuildingByDefault = true;
    # contentAddressedByDefault = true;
  };
}
