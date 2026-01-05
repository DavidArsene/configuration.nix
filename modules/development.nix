{
  pkgs,
  mypkgs,
  newpkgs,
  ...
}:
let
  xconfigDeps = with pkgs; [
    # pkg-config
    # bison
    # flex
    # gnumake
    # stdenv.cc.cc

    qt6.qtbase
    qt6.qttools
  ];

  devishPrograms = with pkgs; [
    # newpkgs.jetbrains-toolbox

    newpkgs.cachix
    newpkgs.devenv
    i2c-tools
    shellcheck-minimal
    kdePackages.kdialog

    # frescobaldi

    # (pkgs.python3Minimal.withPackages (python-pkgs: [
    #  pycryptodome
    #  frida
    # ]))

    # (keystore-explorer.override {
    #   jdk = config.programs.java.package;
    # })

    # jadx
    # apktool
    # scrcpy

    atuin-desktop
  ];

  big-brain-hacker = with pkgs; [
    binwalk
    # edl

    #! mypkgs.ida-pro
    # idea
    (mypkgs.idplugmanager-ro-cei.override { withHiddenFeatures = true; })
  ];

  APPDATA = "/C:/Users/David/AppData";
  product = "JetBrains/IntelliJIdea";
  baseDir = "${APPDATA}/Roaming/${product}";

  idea = (
    mypkgs.better-idea.override {
      extraProperties = {
        # "idea.is.internal" = "true";
        "idea.ignore.plugin.compatibility" = "true";

        "idea.diagnostic.opentelemetry.metrics.file" = "";
        "idea.diagnostic.opentelemetry.meters.file.json" = "";

        "idea.system.path" = "${APPDATA}/Local/${product}";
        "idea.config.path" = baseDir;
        "idea.plugins.path" = "${baseDir}/plugins";
        "idea.log.path" = "/tmp/IntelliJIdeaLogs"; # "${baseDir}/logs";

        "machine.id.disabled" = "true"; # Used by update checker
        # "no.backup" = "true"; # For patch updates, not really useful here
      };
      extraArgs = [
        "-javaagent:/D:/Programs/jetbra/fentanyl.jar=jetbrains"
        "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED"
        "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED"
      ];
    }
  );

in
{
  environment.systemPackages = xconfigDeps ++ devishPrograms ++ big-brain-hacker;
}
