{
  config,
  custom,
  # nix-detsys,
  self,
  ...
}:
{
  nix = {
    settings = {
      accept-flake-config = false;
      # Needed by idea-ultimate
      allow-import-from-derivation = true;
      auto-optimise-store = true;
      build-dir = "/tmp";
      builders-use-substitutes = true;
      # flake-registry = "";
      fallback = false;
      keep-derivations = false; # Includes files from fetch{url,zip}
      # max-jobs = 0; # delegate all builds to server
      sandbox = "relaxed";
      # show-trace = true;
      trusted-substituters = [
        "https://install.determinate.systems"
        "https://nix-community.cachix.org"
      ];
      trusted-users = [ "@wheel" ];
      warn-dirty = false;
    };

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
        sshUser = custom.myself;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
    distributedBuilds = true;

    # package = pkgs.lix;
    # package = (getdef nix-detsys).overrideAttrs (old: {
    #   doCheck = false; # TODO: what causes it to build?
    #   doInstallCheck = false;
    #   withAWS = false;
    # });
    # package = nix-detsys.packages.${pkgs.system}.default.override {
    #   withAWS = false;
    # };
  };

  programs = {
    nix-ld.enable = true;
    # nix-ld.libraries = [];

    nix-index-database.comma.enable = true;
  };

  # nixpkgs.config = {
  # Would replace the boring "-source" suffix
  # with the repo name and version.
  # Unfortunately causes mass rebuild (not even cached).
  # NOTE: CppNix hardcodes "source" for various checks.
  # fetchedSourceNameDefault = "versioned";

  # Same with these:
  # doCheckByDefault = false;
  # enableParallelBuildingByDefault = true;
  # contentAddressedByDefault = true;
  # };

  environment.etc = {
    # Make /etc/nixos point to the local copy of the config,
    # such that all nix commands find it without --flake.
    "nixos".source = "/home/${custom.myself}/.nix/configuration.nix/";

    # Similarly, a link to the version of
    # the config used to build this system.
    "source".source = self;
  };

  system.nixos.label = config.system.nixos.release;
  system.nixos.extraLSBReleaseArgs = {
    LSB_VERSION = "25.11 (Unstable)"; # TODO: fix
    DISTRIB_DESCRIPTION = "NixOS Enterprise ${config.system.nixos.release}";
  };

  environment.localBinInPath = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # TODO: Requires systemd in initrd, ruins my initrd-less boot plans
  #  system.etc.overlay.enable = true;
  #  system.etc.overlay.mutable = false;
  #  system.nixos-init.enable = true;
  #  boot.initrd.systemd.enable = true;
  #  boot.initrd.systemd.emergencyAccess = config.users.users.${custom.myself}.hashedPassword;
  # boot.initrd.clevis.enable = true;
  boot.initrd.checkJournalingFS = true;
  #  services.userborn.enable = true;
  # systemd.sysusers.enable = true;
}
