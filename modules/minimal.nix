{
  config,
  edge ? pkgs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
with lib;
let

  disableForce = {
    enable = mkForce false;
  };

  disableDefault = {
    enable = mkDefault false;
  };

  FALSE = mkForce false;

in
{
  # +---------------------------------+
  # | Added from profiles/minimal.nix |
  # |      Watch it for updates       |
  # +---------------------------------+

  documentation = disableForce // {
    doc = disableForce;
    info = disableForce;
    nixos = disableForce;
    man = disableForce // {
      man-db = disableForce;
    };
  };

  xdg = {
    autostart = disableDefault;
    icons = disableDefault;
    mime = disableDefault;
    sounds = disableDefault;
  };

  # +-----------------------------+
  # | What even is "environment", |
  # | and how is it grouped?      |
  # +-----------------------------+

  environment = {
    defaultPackages = mkForce [ ];
    stub-ld = disableDefault;

    plasma6.excludePackages = with pkgs.kdePackages; [
      # aurorae
      # plasma-browser-integration
      plasma-workspace-wallpapers
      # konsole
      kwin-x11
      # (lib.getBin qttools) # Expose qdbus in PATH
      # ark
      # elisa
      # gwenview
      # okular
      # kate
      # ktexteditor # provides elevated actions for kate
      khelpcenter
      # dolphin
      # baloo-widgets # baloo information in Dolphin
      # dolphin-plugins
      # spectacle
      ffmpegthumbs
      krdp
      xwaylandvideobridge # exposes Wayland windows to X11 screen capture
    ];
  };

  # —————————————No perl?————————————————
  # ⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
  # ⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
  # ⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
  # ⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
  # ⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
  # ⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
  # ⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  # ⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  # —————————————————————————————

  programs = {
    less.lessopen = mkForce null;
    command-not-found = disableForce;
    fish.generateCompletions = mkDefault false;

    git.package = edge.gitMinimal;
    firefox.wrapperConfig = {
      speechSynthesisSupport = false;
    };

    # TODO: kinda breaks everything
    # xwayland = disableForce;
  };

  services = {
    logrotate = disableDefault;
    udisks2 = disableDefault;

    # No accessibility, I want my system inaccessible
    orca = disableForce; # Screen reader
    speechd = disableForce; # TTS

    # Saving the planet, one paper at a time
    printing = disableForce;

    # all alone here, so sad
    desktopManager.plasma6.enableQt5Integration = FALSE;
  };

  # less wear on my precious ssd
  boot.tmp = {
    useTmpfs = mkDefault true;
    tmpfsHugeMemoryPages = "within_size";

    # Why no work‽
    # useZram = true;
    # zramSettings.zram-size = "ram * 1"; # X-mount?
    # zramSettings.options = "mode=0755,discard";
  };

  # Who needs firewalls anyway?
  # NAT already does this!
  networking.firewall = disableForce;

  # Oh come on, who even uses modems \
  # enough to enable this by default?
  networking.modemmanager = disableForce;

  # +-------------------------------------+
  # | Now we're getting to the good stuff |
  # +-------------------------------------+

  # Installer? I barely know her!
  # $installerTools = nixos-{build-vms,enter,generate-config,install,option,rebuild,version}
  system.disableInstallerTools = mkForce true; # TODO: nixos-{install,option}?

  # !!! Ok fine maybe nixos-rebuild is necessary !!!
  environment.systemPackages = [

    # Recreation of nixos-rebuild with nicer ^C handling
    (edge.callPackage ../pkgs/nixos-rebuild-ng { inherit config; })
  ];

  # +------------------+
  # | Reduce eval time |
  # +------------------+

  nixpkgs.config = {
    allowAliases = false;
    allowVariants = false;
  };

  lib = lib // {
    mkAliasOptionModule = (_: null);
    mkMergedOptionModule = (_: null);
    mkChangedOptionModule = (_: null);
    mkRemovedOptionModule = (_: null);
    mkRenamedOptionModule = (_: null);
  };

  #

  hardware = {
    firmware = with edge; [
      # linux-firmware

      # intel2200BGFirmware
      # rtl8192su-firmware
      # rt5677-firmware
      # rtl8761b-firmware
      # zd1211fw
      # alsa-firmware
      # sof-firmware
      # libreelec-dvb-firmware

      wireless-regdb
    ];

    enableAllFirmware = FALSE;
    enableRedistributableFirmware = FALSE;
  };

  # +----------------------------------------------------------+
  # | And then all the random stuff, Miscellaneous if you will |
  # +----------------------------------------------------------+

  # I can't read
  systemd.coredump.extraConfig = "Storage=none";

  # No need to type either
  i18n.inputMethod = disableForce;

  security.pam.services.su.forwardXAuth = FALSE;

  # TODO: ensure-all-wrappers-paths-exist
  # https://www.reddit.com/r/NixOS/comments/19595vc/comment/khzdgw8
  environment.etc =
    builtins.attrNames specialArgs
    |> filter (p: !builtins.elem p [ "edge" ])
    |> map (
      input:
      attrsets.nameValuePair "sources/${input}" {
        enable = true;
        source = specialArgs.${input};
        mode = "symlink";
      }
    )
    |> listToAttrs;

  # Too much
  # fonts.fontconfig = disableForce;

  # system.extraDependencies = specialArgs;
}
