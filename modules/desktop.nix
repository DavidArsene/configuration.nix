{
  pkgs,
  newpkgs,
  helium,
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
      kamera
      kamoso
      # karton
      # kasts
      kbackup
      kcalc
      kcharselect
      # kdenlive
      # kget
      kgraphviewer
      kmousetool
      kompare
      krohnkite
      ktouch
      # krusader
      # konqueror
      krfb
      kweather
      milou
      plasma-disks
      powerdevil
      sierra-breeze-enhanced

      oxygen
      oxygen-icons
      oxygen-sounds

      #* Obscure KDE
      ksystemlog
      kdebugsettings
      keysmith # 2FA
      kio-gdrive
      sweeper
      systemdgenie

      #* Everything else
      btrfs-assistant
      # easyeffects
      # fooyin
      karousel
      # keepassxc # still on qt5
      klassy
      # kontainer
      linux-wifi-hotspot
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
      unar # test for ark
      waycheck
      wl-clipboard-rs

      # kwin-blur.packages.${config.users.system}.default
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

    peazip
    gpu-screen-recorder # TODO: -qt
    mitmproxy

    # opendrop
    packet
    # rquickshare

    #> And less frequently used
    cryptsetup
    tpm2-pkcs11
    tpm2-tools
    tpm2-totp
    uefisettings
    # WAITPR onlyoffice-desktopeditors # TODO: move to programs.onlyoffice

    # mypkgs.libreoffice
    # collabora-desktop
    helium.packages.${pkgs.stdenv.system}.helium

  ];
  newPackages = with newpkgs; [
    # appimageupdate

    btrfs-heatmap
    compsize
    cpu-x
    ntfsprogs-plus
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
    NIXOS_OZONE_WL = 1;
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

    plasma-workspace-wallpapers
  ];

  environment.systemPackages = qtPackages ++ otherPackages ++ newPackages;
}
