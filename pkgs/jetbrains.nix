{
  lib,
  pkgs,

  removedPlugins ? [
    # Other Products
    "cwm-plugin"
    "DatabaseTools"
    "fullLine"
    "grazie"
    "liquibase"
    "qodana"
    "station-plugin" # bundled Toolbox?
    "swagger"

    # Misc Components / Features
    "clouds-*"
    "gateway-plugin"
    # "vcs-{svn,perforce,hg}"
    "vcs-hg"
    "vcs-svn"
    "vcs-perforce"
    "remote-dev-server"
    "ijent" # ??
    "localization-*"
    "mcpserver"
    "jupyter-plugin"
    "kotlin-jupyter-plugin"
    "textmate"

    # Web Development
    "angular"
    "css-impl"
    "javascript-*"
    "nodeJS*"
    "restClient"
    "sass"
    "tailwindcss"
    "vuejs"
    "web*" # TODO: without webp

    # Unironic Java
    "Spring"
    "spring-*"
    "JavaEE"
    "javaee-*"
    "java-coverage"
  ],
}:

let
  fetch7z = import ./fetch7z { inherit pkgs lib; };

  jbr = pkgs.jetbrains.jdk;

  mvn = pkgs.maven.override {
    jdk_headless = jbr;
  };

  idea-ultimate =
    with pkgs;
    stdenv.mkDerivation rec {

      pname = "idea-ultimate";
      meta = {
        homepage = "https://www.jetbrains.com/idea/";
        description = "IntelliJ IDEA Ultimate Pro Max";
        mainProgram = pname;
        teams = [ lib.teams.jetbrains ];
        license = lib.licenses.unfree;
        sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
      };

      version = "2025.2";
      src = fetch7z {
        url = "https://download.jetbrains.com/idea/ideaIU-${version}.tar.gz";
        sha256 = "sha256-EGWgMTM5TRxwuk4pahhqyfIW8+TZzyKuk4A55G6aUgY=";

        stripRoot = false;
        recurse = false;
        listWhatTemp = lib.map (p: ''"*"/'' + p) [
          "bin"
          "lib"
          "modules"
          "plugins"
        ];
        exclude = lib.map (p: ''"*"/plugins/'' + p) removedPlugins;
      };

      # Manual unpacking that skips files instead of removing them later
      UNUSED.unpackPhase = ''
        mkdir -p $out/app
        tar -xvzf $src \
          -C $out/app \
          --wildcards \
          --strip-components 1 \
          -X <(echo "idea-*"/plugins/{${lib.concatStringsSep "," removedPlugins}}) \
          "idea-*"/{bin,lib,modules,plugins}
      '';

      passthru.buildNumber = "252.23892.409";

      desktopItem = makeDesktopItem {
        name = pname;
        exec = pname;
        icon = pname;
        comment = meta.description;
        # genericName = meta.description;
        desktopName = "Bad IDEA";
        categories = [ "Development" ];
        startupWMClass = "jetbrains-idea";
      };

      nativeBuildInputs = [
        makeWrapper
        patchelf
        autoPatchelfHook
      ];

      buildInputs = [
        stdenv.cc.cc
        lldb
        musl
      ];

      postPatch = ''
        ln -s ${jbr.home} jbr

        echo -Djna.library.path=${
          lib.makeLibraryPath [
            libsecret
            e2fsprogs
            libnotify
            # Required for Help -> Collect Logs
            # in at least rider and goland
            udev
          ]
        } >> bin/idea64.vmoptions
      '';

      installPhase = ''
        runHook preInstall

        # JetBrains Client is part of Code With Me
        rm $out/app/bin/{fsnotifier,idea,jetbrains_client*,remote-dev-server*}

        mkdir -p $out/{bin,share/pixmaps,share/icons/hicolor/scalable/apps}
        # cp -a . $out/app # wasting space smh
        ln -s $out/app/bin/idea.png $out/share/pixmaps/${pname}.png
        ln -s $out/app/bin/idea.svg $out/share/pixmaps/${pname}.svg
        ln -s $out/app/bin/idea.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg

        ln -s ${libdbusmenu}/lib/libdbusmenu.so $out/app/bin/libdbm.so
        ln -s ${fsnotifier}/bin/fsnotifier $out/app/bin/fsnotifier

        jdk=${jbr.home}
        launcher="$out/app/bin/idea.sh"

        wrapProgram "$launcher" \
          --prefix PATH : "${
            lib.makeBinPath [
              jbr

              coreutils
              gnugrep
              which
              git
            ]
          }" \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              libGL
              zlib
            ]
          }" \
          # IJ-specific
          --set M2_HOME "${mvn}/maven" \
          --set M2 "${mvn}/maven/bin" \

          --set-default JDK_HOME "$jdk" \
          --set-default JAVA_HOME "$jdk" \
          --set-default IDEA_JDK "$jdk" \
          --set-default ANDROID_JAVA_HOME "$jdk" \
          --set-default LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive"

        # Use shell script instead of Rust launcher, maybe aarch64 will work?
        ln -s "$launcher" $out/bin/${pname}
        ln -s "${desktopItem}/share/applications" $out/share

        runHook postInstall
      '';

      # TODO: combine with RustRover and Android Studio
      # postFixup = (attrs.postFixup or "") ''
      #   cd $out/rust-rover

      #   # Copied over from clion (gdb seems to have a couple of patches)
      #   ls -d $PWD/bin/gdb/linux/*/lib/python3.8/lib-dynload/* |
      #   xargs patchelf \
      #     --replace-needed libssl.so.10 libssl.so \
      #     --replace-needed libcrypto.so.10 libcrypto.so

      #   ls -d $PWD/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
      #   xargs patchelf \
      #     --replace-needed libssl.so.10 libssl.so \
      #     --replace-needed libcrypto.so.10 libcrypto.so
      # '';

    };
  # communitySources = callPackage ./source { };
in

{
  inherit idea-ultimate;

  # rust-rover =
  #   (mkJetBrainsProduct {
  #     pname = "rust-rover";
  #     extraBuildInputs = lib.optionals (stdenv.hostPlatform.isLinux) [
  #       python3
  #       openssl
  #       libxcrypt-legacy
  #       fontconfig
  #       # xorg.libX11
  #     ];
  #   }).overrideAttrs
  #     (attrs: {
  #     });

  # plugins = callPackage ./plugins { } // {
  #   __attrsFailEvaluation = true;
  # };

}
