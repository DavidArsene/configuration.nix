{
  config,
  edge,
  # kwin-blur,
  pkgs,
  ...
}:
let

  # QT apps need a consistent set of Qt libraries
  qtPackages =
    with pkgs;
    with pkgs.kdePackages;
    [
      # Official KDE
      falkon
      filelight
      kate
      kcalc
      kcharselect
      kasts
      kdeconnect-kde
      kdevelop
      # krita # after qt6 migration
      plasma-sdk
      yakuake

      # Everything else
      btrfs-assistant
      karousel
      qalculate-qt
      qbittorrent
      qc
      qMasterPassword-wayland
      qownnotes
      qdirstat
      # supergfxctl-plasmoid
      waycheck

      # darkly
      # pkgs.nur.repos.shadowrz.klassy-qt6
      # kwin-blur.packages.${pkgs.system}.default
    ];

  # Larger apps to be updated slower
  otherPackages = with pkgs; [
    # Use same Electron version
    vesktop
    zapzap
    # mitmproxy
    # httptoolkit
    # p3x-onenote
  
    vscodium-fhs
    # onlyoffice-desktopeditors

    # (callPackage ../pkgs/libreoffice.nix { })
    (callPackage ../pkgs/ida-pro.nix { })
    # (callPackage ../pkgs/jetbrains.nix { }).idea-ultimate

    vivaldi

    cmakeMinimal # for KDevelop
  ];

  edgePackages = with edge; [
    # cromite
    # ungoogled-chromium
    mission-center
    # trayscale
    # waydroid-helper

    cryptsetup
    uefisettings
    uefitool
    tpm2-pkcs11
    tpm2-tools
    tpm2-totp

    btrfs-heatmap

    pciutils
    usbtop
    usbutils

    librespot
    spotify-qt

    # ---
    # (keystore-explorer.override {
    #   jdk = config.programs.java.package;
    # })
  ];

in

{
  # Use NetworkManager on desktop for easy Wi-Fi
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = [ ];

    wifi.backend = "iwd";
    wifi.powersave = true;
    # todo sh -c 'echo 2 > /proc/sys/net/ipv6/conf/wlan0/use_tempaddr' failed with exit code 1.
  };
  # Why are these two not linked?
  # Tailscale fooled me by providing its own DNS resolver,
  # leading to network being broken when not used.
  services.resolved.enable = !config.services.tailscale.enable;
  # TODO: meh

  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    udisks2.mountOnMedia = true;
  };

  # Recommended by Darkly
  # KDE Settings will not work anymore; use `Qt6 Settings`
  # qt.platformTheme = "qt5ct";
  # qt.style = "kvantum";

  security.rtkit.enable = true;

  environment.systemPackages = qtPackages ++ otherPackages ++ edgePackages;

  # GUI Programs
  programs = {
    firefox.enable = true;

    kde-pim.enable = false;
    partition-manager.enable = true;
  };

  # TODO: shortcut
  # qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole

  # What's the difference between NFM and NF fonts?
  # https://github.com/ryanoasis/nerd-fonts/discussions/945
  fonts.packages = with pkgs.nerd-fonts; [
    # code-new-roman
    # comic-shanns-mono
    # commit-mono
    jetbrains-mono
    symbols-only
  ];
}
