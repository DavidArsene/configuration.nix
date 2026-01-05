{
  custom,
  mylib,
  pkgs,
  mypkgs,
  newpkgs,
  kwin-blur,
  # zen,
  ...
}:
let
  kpkgs = pkgs.kdePackages;

  #? QT apps need a consistent set of Qt libraries
  qtPackages =
    with pkgs;
    with kpkgs;
    [
      #* Official KDE
      filelight
      kate
      kdeconnect-kde
      # kdevelop
      # krita #* after qt6 migration
      plasma-sdk
      yakuake

      # TODO: .desktop file for qdbusviewer

      #* Random KDE
      # falkon
      # kasts
      kcalc
      kcharselect
      # kdenlive
      krusader
      konqueror

      #* Obscure KDE
      ksystemlog
      kdebugsettings
      keysmith

      #* Everything else
      btrfs-assistant
      # easyeffects
      karousel
      notify-desktop
      qalculate-qt
      qbittorrent
      qc
      qMasterPassword-wayland
      # qownnotes
      (mylib.mkFreshOnly qdirstat)
      uefitool
      waycheck

      kwin-blur.packages.${custom.system}.default

      nixd # TODO: for kate
    ];

  #? Larger apps to be updated slower
  otherPackages = with pkgs; [
    #> Use same Electron version
    equibop # Vencord fork
    zapzap
    # ayugram-desktop
    # losslesscut-bin
    # newpkgs.beeper

    mitmproxy
    # p3x-onenote

    #> And less frequently used
    cryptsetup
    tpm2-pkcs11
    tpm2-tools
    tpm2-totp
    uefisettings
    # onlyoffice-desktopeditors

    # mypkgs.libreoffice
    mypkgs.helium

    # ];
    # edgePackages = with newpkgs; [

    # TODO: remove policies when issue
    #    (mylib.mkFreshOnly (
    #      zen.packages.${custom.system}.twilight.override { extraPolicies = firefoxPolicies; }
    #    ))

    # appimageupdate

    btrfs-heatmap
    compsize

    pciutils
    usbtop
    usbutils
  ];

  #!
  #! TODO: RDP Server
  #!

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
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    udisks2.mountOnMedia = true;
  };

  environment.sessionVariables = {
    KWIN_USE_OVERLAYS = 1;
  };

  security.rtkit.enable = true;

  #> GUI Programs
  programs = {
    partition-manager.enable = true;
    # appimage.enable = true;
    # appimage.binfmt = true;
  };

  #? Difference between NFM and NF fonts
  #? https://github.com/ryanoasis/nerd-fonts/discussions/945
  fonts.packages =
    with pkgs;
    with nerd-fonts;
    [
      noto-fonts-color-emoji
      # twemoji-color-font
      # code-new-roman
      # comic-shanns-mono
      # commit-mono
      # jetbrains-mono
      symbols-only
    ];

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.panel = "${kpkgs.plasma-desktop}/libexec/kimpanel-ibus-panel";
    ibus.engines = with pkgs.ibus-engines; [
      uniemoji
      (typing-booster.override {
        langs = [
          "en-us-large"
          "ro-ro"
        ];
      })
    ];
  };

  environment.systemPackages =
    qtPackages
    ++ otherPackages
    # ++ edgePackages
    ++ (with kpkgs; [
      # qtimageformats # provides optional image formats such as .webp and .avif
      kio # provides helper service + a bunch of other stuff
      kio-admin # managing files as admin
      kio-extras # stuff for MTP, AFC, etc
      kio-fuse # fuse interface for KIO
      knighttime # night mode switching daemon
      kpackage # provides kpackagetool tool
      kwalletmanager # provides KCMs and stuff
      solid # provides solid-hardware6 tool
      kdegraphics-thumbnailers # pdf etc thumbnailer
      kde-gtk-config # syncs KDE settings to GTK
      breeze-gtk
      ocean-sound-theme
      # pkgs.hicolor-icon-theme # fallback icons
      kmenuedit
      kinfocenter
      plasma-systemmonitor
      aurorae
      plasma-browser-integration
      konsole
      ark
      gwenview
      okular
      kate
      ktexteditor # provides elevated actions for kate
      dolphin
      baloo-widgets # baloo information in Dolphin
      dolphin-plugins
      spectacle
      krdp
    ]);
}
