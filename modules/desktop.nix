{
  config,
  custom,
  mylib,
  edge ? pkgs,
  pkgs,
  zen,
  ...
}:
let

  #> QT apps need a consistent set of Qt libraries
  qtPackages =
    with pkgs;
    with pkgs.kdePackages;
    [
      #> Official KDE
      filelight
      kate
      kdeconnect-kde
      # kdevelop
      # krita # after qt6 migration
      plasma-sdk
      yakuake

      # TODO: .desktop file for qdbusviewer

      #> Random KDE
      # falkon
      # kasts
      kcalc
      kcharselect
      # kdenlive
      krusader
      konqueror

      #> Obscure KDE
      # calligra
      ksystemlog
      # kgpg
      # kleopatra
      kdebugsettings
      #      kmahjongg
      #      marble
      #      okteta
      #      elf-dissector

      #> Everything else
      btrfs-assistant
      karousel
      qalculate-qt
      qbittorrent
      qc
      qMasterPassword-wayland
      # qownnotes
      (mylib.mkFreshOnly qdirstat)
      # spotify-qt
      # supergfxctl-plasmoid
      uefitool
      waycheck
    ];

  #> Larger apps to be updated slower
  otherPackages = with pkgs; [
    #> Use same Electron version
    (mylib.mkFreshOnly vesktop)
    (mylib.mkFreshOnly zapzap)
    # equicord # Vencord fork
    # ayugram-desktop

    mitmproxy
    # httptoolkit
    # p3x-onenote

    #> And less frequently used
    cryptsetup
    tpm2-pkcs11
    tpm2-tools
    tpm2-totp
    # onlyoffice-desktopeditors

    # (callPackage ../pkgs/libreoffice.nix { })
  ];

  edgePackages = with edge; [
    # TODO: remove policies when issue
    #! (zen.packages.${custom.system}.twilight.override { extraPolicies = firefoxPolicies; })
    # cromite

    # mission-center
    # trayscale
    # waydroid-helper

    uefisettings

    btrfs-heatmap
    compsize

    pciutils
    usbtop
    usbutils

    # librespot
  ];

  firefoxPolicies = {
    CaptivePortal = false;
    Cookies.Behavior = "reject-foreign";
    DisableAppUpdate = true;
    DisableFirefoxStudies = false; # see about:studies
    DisableProfileRefresh = true;
    DisableSetDesktopBackground = true;
    DisableTelemetry = false;
    # DNSOverHTTPS
    DontCheckDefaultBrowser = true;
    EnableTrackingProtection.Value = false; # uBlock?
    # ExtensionUpdate
    # FirefoxHome
    # GoToIntranetSiteForSingleWordEntryInAddressBar
    # LegacyProfiles
  };

in

{
  #> Use NetworkManager on desktop for easy Wi-Fi
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = [ ];

    wifi.backend = "iwd";
    wifi.powersave = true;
    # todo sh -c 'echo 2 > /proc/sys/net/ipv6/conf/wlan0/use_tempaddr' failed with exit code 1.
  };
  #> Why are these two not linked?
  #> Tailscale fooled me by providing its own DNS resolver,
  #> leading to network being broken when not used.
  services.resolved.enable = !config.services.tailscale.enable;
  # TODO: meh

  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    udisks2.mountOnMedia = true;
  };

  environment.sessionVariables = {
    KWIN_USE_OVERLAYS = 1;
  };

  security.rtkit.enable = true;

  environment.systemPackages = qtPackages ++ otherPackages ++ edgePackages;

  #> GUI Programs
  programs = {
    partition-manager.enable = true;
  };

  #> What's the difference between NFM and NF fonts?
  #> https://github.com/ryanoasis/nerd-fonts/discussions/945
  fonts.packages =
    with pkgs;
    with pkgs.nerd-fonts;
    [
      # twemoji-color-font
      # code-new-roman
      # comic-shanns-mono
      # commit-mono
      # jetbrains-mono
      symbols-only
    ];
}
