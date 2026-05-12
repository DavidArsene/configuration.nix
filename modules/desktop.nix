{
  mylib,
  pkgs,
  mypkgs,
  newpkgs,
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
      systemdgenie

      #* Everything else
      btrfs-assistant
      # easyeffects
      karousel
      # keepassxc # still on qt5
      kontainer
      notify-desktop
      qalculate-qt
      qbittorrent
      qc
      # qMasterPassword
      # qownnotes
      qdirstat
      qt6.qttools
      tail-tray # trayscale but qt
      uefitool
      waycheck
      wl-clipboard-rs

      # kwin-blur.packages.${custom.system}.default

      # nixd # TODO: for kate
    ];

  #? Larger apps to be updated slower
  otherPackages = with pkgs; [
    #> Use same Electron version
    equibop # Vencord fork
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
    # onlyoffice-desktopeditors

    # mypkgs.libreoffice
    mypkgs.helium

  ];
  newPackages = with newpkgs; [
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
in

{
  services = {
    displayManager.plasma-login-manager.enable = true;
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

  environment.systemPackages =
    qtPackages
    ++ otherPackages
    ++ newPackages
    ++ (with kpkgs; [
      # qtimageformats # provides optional image formats such as .webp and .avif
      # kdegraphics-thumbnailers # pdf etc thumbnailer
      aurorae
      plasma-browser-integration
      konsole
      ark
      gwenview
      # okular
      kate
      ktexteditor # provides elevated actions for kate
      dolphin
      baloo-widgets # baloo information in Dolphin
      dolphin-plugins
      spectacle
      krdp
    ]);
}
