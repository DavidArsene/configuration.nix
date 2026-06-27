{
  pkgs,
  newpkgs,
  helium-flake,
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
      # krita
      plasma-sdk
      yakuake

      # TODO: .desktop file for qdbusviewer

      #* Random KDE
      # falkon
      # karton
      # kasts
      kcalc
      kcharselect
      # kdenlive
      # krusader
      # konqueror
      krfb
      kweather

      #* Obscure KDE
      ksystemlog
      kdebugsettings
      keysmith # 2FA
      kio-gdrive
      systemdgenie

      #* Everything else
      btrfs-assistant
      # easyeffects
      karousel
      # keepassxc # still on qt5
      # kontainer
      notify-desktop
      qalculate-qt
      ## qbittorrent
      qc
      # qMasterPassword
      # qownnotes
      qdirstat
      qt6.qttools
      tail-tray # trayscale but qt
      uefitool
      unar # test for ark
      waycheck
      wl-clipboard-rs

      # kwin-blur.packages.${custom.system}.default
      # mypkgs.kde-shader-wallpaper
      plasma-panel-colorizer

      # nixd # TODO: for kate
    ];

  #? Larger apps to be updated slower
  otherPackages = with pkgs; [
    #> Use same Electron version
    # ayugram-desktop
    # losslesscut-bin
    # newpkgs.beeper

    mitmproxy

    opendrop
    packet
    # rquickshare

    #> And less frequently used
    cryptsetup
    tpm2-pkcs11
    tpm2-tools
    tpm2-totp
    uefisettings
    # onlyoffice-desktopeditors # TODO: move to programs.onlyoffice
    # terminal-rain

    # mypkgs.libreoffice
    (callPackage (helium-flake + /helium.nix) {
      libICE = libice;
      libSM = libsm;
      libX11 = libx11;
      libXScrnSaver = libxscrnsaver;
      libXcomposite = libxcomposite;
      libXcursor = libxcursor;
      libXdamage = libxdamage;
      libXext = libxext;
      libXfixes = libxfixes;
      libXft = libxft;
      libXi = libxi;
      libXrandr = libxrandr;
      libXrender = libxrender;
      libXt = libxt;
      libXtst = libxtst;
    })

  ];
  newPackages = with newpkgs; [
    # appimageupdate

    btrfs-heatmap
    compsize
    cpu-x
    uxplay

    pciutils
    usbtop
    usbutils
  ];

in

{
  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;

    udisks2.mountOnMedia = true;

    # TODO: smartd the rest
    smartd.notifications.test = true;
  };

  environment.sessionVariables = {
    KWIN_USE_OVERLAYS = 1;
    # QT_QUICK_CONTROLS_STYLE = "org.kde.union"; # 🎉
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
      corefonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans # -static
      # twemoji-color-font

      # code-new-roman
      # comic-shanns-mono
      # commit-mono
      # jetbrains-mono
      symbols-only
    ];

  i18n.inputMethod = {
    enable = false; # ! FIXME
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

  environment.plasma6.excludePackages = with kpkgs; [
    phonon-vlc
    kdegraphics-thumbnailers
    kwin-x11
    elisa
    okular
    khelpcenter
    ffmpegthumbs
  ];

  environment.systemPackages = qtPackages ++ otherPackages ++ newPackages;
}
