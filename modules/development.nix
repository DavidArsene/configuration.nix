{
  config,
  pkgs,
  mylib,
  mypkgs,
  newpkgs,
  ...
}:
let
  idea = mypkgs.better-idea.override {

    jbr' = config.programs.java.package;

    extraPackages = with newpkgs; [
      fish-lsp

      gnumake
      meson

      pkgs.nixd
      pkgs.nixfmt

      # ruff
      # ty
      # basedpyright
      # pyrefly
      # zuban
    ];

    extraProperties =
      let
        baseDir = "/david/IntelliJIdea";
      in
      {
        "idea.is.internal" = "true";
        "idea.ignore.plugin.compatibility" = "true";

        "idea.diagnostic.opentelemetry.metrics.file" = "";
        "idea.diagnostic.opentelemetry.meters.file.json" = "";

        "idea.system.path" = "${baseDir}/system";
        "idea.config.path" = "${baseDir}/config";
        "idea.plugins.path" = "${baseDir}/plugins";
        "idea.log.path" = "/tmp/IntelliJIdeaLogs"; # "${baseDir}/logs";

        "machine.id.disabled" = "true"; # Used by update checker
      };

    extraArgs = [ "-javaagent:/home/david/jrebel.jar" ];
  };

in
{
  environment.systemPackages = with pkgs; [
    cachix
    # newpkgs.devenv
    i2c-tools
    shellcheck-minimal
    kdePackages.kdialog

    # oci-cli
    # opentofu
    step-ca
    step-cli
    # global-platform-pro

    # frescobaldi

    #? Python with some commonly used (by me) dependencies
    #! Does not work with python3Minimal
    (python3.withPackages (
      pypkgs: with pypkgs; [
        cffi
        pip
        pycryptodome
        # pyside6
        requests
        # frida
      ]
    ))

    (keystore-explorer.override { jdk17 = config.programs.java.package; })

    (mypkgs.jadx-bin.override { jre = config.programs.java.package; })
    # apktool
    # scrcpy

    # ytdl-sub
    xlsclients # -a -l
    # atuin-desktop

    # zed-editor

    binwalk
    # edl
    wireshark

    nix-init

    idea
    mypkgs.idplugmanager-ro-cei
    mypkgs.ida-pro
  ];
}
