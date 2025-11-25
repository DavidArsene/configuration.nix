{
  edge ? pkgs,
  pkgs,
  mypkgs,
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

  devishPrograms = with edge; [
    i2c-tools
    shellcheck-minimal
    kdePackages.kdialog

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
  ];

  APPDATA = "/C:/Users/David/AppData";
  product = "JetBrains/IntelliJIdea";
  baseDir = "${APPDATA}/Roaming/${product}";

  big-brain-hacker = with pkgs; [
    binwalk
    # edl
    mtkclient

    #! mypkgs.ida-pro

    /*
      (mypkgs.idea-aio.override {
        extraProperties = {
          "idea.ignore.plugin.compatibility" = "true";
          "ide.browser.jcef.sandbox.enable" = "false";

          "idea.system.path" = "${APPDATA}/Local/${product}";
          "idea.config.path" = baseDir;
          "idea.plugins.path" = "${baseDir}/plugins";
          "idea.log.path" = "/tmp/IntelliJIdeaLogs"; # "${baseDir}/logs";
        };
        extraArgs = [
          "-Dno.backup=true"

          "-javaagent:/D:/Programs/jetbra/fentanyl.jar=jetbrains"
          "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED"
          "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED"

          "-Didea.diagnostic.opentelemetry.metrics.file="
          "-Didea.diagnostic.opentelemetry.meters.file.json="
        ];
        withDebugFeatures = true;
      })
    */
  ];

in
{
  environment.systemPackages = xconfigDeps ++ devishPrograms ++ big-brain-hacker;
}
