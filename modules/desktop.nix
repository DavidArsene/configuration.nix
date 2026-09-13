{
  pkgs,
  newpkgs,
  mypkgs,
  helium,
  kwin-blur,
  ...
}:
let
  kpkgs = pkgs.kdePackages;

  #? QT apps need a consistent set of Qt libraries
  qtPackages =
    with pkgs;
    with kpkgs;
    [
      drawy
      # falkon
      filelight
      kamera
      kamoso
      karousel
      # karton
      # kasts
      kate
      kbackup
      kcalc
      kcharselect
      kdebugsettings
      kdeconnect-kde
      # kdenlive
      # kdevelop
      keysmith # 2FA
      # kget
      kgraphviewer
      kio-gdrive
      klassy
      kmousetool
      kompare
      # kontainer
      # konqueror
      krfb
      # krita
      krohnkite
      # krusader
      ksystemlog
      ktouch
      kweather
      milou
      oxygen
      oxygen-icons
      oxygen-sounds
      plasma-disks
      plasma-panel-colorizer
      plasma-sdk
      powerdevil
      sierra-breeze-enhanced
      sweeper
      systemdgenie

      #* Everything else
      btrfs-assistant
      # easyeffects
      # fooyin
      # keepassxc # still on qt5
      linux-wifi-hotspot
      notify-desktop
      qalculate-qt
      qbittorrent
      qc
      # qMasterPassword
      # qownnotes
      qdirstat
      qt6.qttools
      # tail-tray # trayscale but qt
      uefitool
      unar # test for ark
      waycheck
      wl-clipboard-rs

      kwin-blur.packages.${pkgs.stdenv.system}.default
      mypkgs.kde-shader-wallpaper
    ]
    ++
      # testing .desktop files for already installed pkgs
      [
        geoclue2
        v4l-utils
      ];

  #? Larger apps to be updated slower
  otherPackages = with pkgs; [
    #> Use same Electron version
    # ayugram-desktop
    # losslesscut-bin
    # newpkgs.beeper

    peazip
    mitmproxy

    # opendrop
    packet
    # rquickshare

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

    howdy.enable = false; # no ir :(
    howdy.settings = {
      core = {
        detection_notice = true; # Notify about detection
        use_cnn = true; # Better model
        # workaround = "off";
      };
      video = {
        certainty = 3.5; # 1 to 10, the lower, the more accurate
        timeout = 4;
        max_height = 720;
        # recording_plugin = "opencv";
      };
      rubberstamps = {
        enabled = true;
        stamp_rules = "TODO";
      };
    };
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
    gpu-screen-recorder.enable = true;
    gpu-screen-recorder.ui.enable = true;
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
