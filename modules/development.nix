{
  pkgs,
  mylib,
  mypkgs,
  newpkgs,
  ...
}:
let
  devishPrograms = with pkgs; [
    newpkgs.cachix
    # newpkgs.devenv
    i2c-tools
    shellcheck-minimal
    kdePackages.kdialog

    # oci-cli
    opentofu
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
        pyside6
        requests
        # frida
      ]
    ))

    # (keystore-explorer.override {
    #   jdk = config.programs.java.package;
    # })

    # jadx
    # apktool
    # scrcpy

    # ytdl-sub
    xlsclients # -a -l
    # atuin-desktop

    # zed-editor
  ];

  big-brain-hacker = with pkgs; [
    binwalk
    # edl

    idea
    mypkgs.idplugmanager-ro-cei
  ];

  APPDATA = "/media/Windows/Users/David/AppData";
  product = "JetBrains/IntelliJIdea";
  baseDir = "${APPDATA}/Roaming/${product}";

  # >This plugin enhances PyCharm with integrated support for ty, pyrefly, ruff, pyright, and base LSP tooling. It provides fast linting with ruff, precise type checking with pyright, ty and pyrefly. The plugin works with minimal configuration.
  idea = mypkgs.better-idea.override {
    extraPackages = with newpkgs; [
      fish-lsp

      nixd
      nixfmt

      ruff
      ty
      # basedpyright
      pyrefly
      zuban
    ];
    extraProperties = {
      "idea.is.internal" = "true";
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
      "-javaagent:/home/david/jrebel.jar"
      "--add-opens=java.base/sun.net.www.http=ALL-UNNAMED"
      "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED"
      "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED"
    ];
  };

in
{
  environment.systemPackages = devishPrograms ++ big-brain-hacker;
}
