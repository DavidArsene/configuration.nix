{
  edge ? pkgs,
  config,
  pkgs,
  mylib,
  # mypkgs,
  ...
}:
{
  # TODO: find x86_64-v4 precompileds
  environment.systemPackages = (
    with edge;
    [
      # Nix
      nix-tree
      # nix-update TODO:
      # nix-forecast
      # nix-du
      # nix-fast-build
      # nix-inspect
      # nix-locate
      nix-output-monitor
      dix
      manix

      # Modern utilities
      bat # cat
      btop # htop
      curlie # curl
      delta # diff
      eza # ls
      fd # everybody hates gnu find
      glances
      kmon
      ripgrep # grep
      xh # wget
      zenith # htop

      # Everything else
      binutils
      fatrace
      file
      gh
      imagemagick
      isd
      lshw
      lsof
      modprobed-db
      p7zip # -rar # needs building
      psmisc
      qrencode
      smartmontools
      strace
      strace-analyzer
      # sysdig # big deps
      tinyxxd

      # sigh why not already in path
      jq
      which
      wget

      # clevis # TODO: pulls asciidoc and the entire LaTeX toolchain
      efivar
      efitools
      efibootmgr
      keyutils
      sbctl
      sbsigntool

      rustup
    ]
  );

  programs.java = {
    enable = false; # main difference: sets variable by shell init
    # package = mypkgs.zing;
    package = mylib.mkFreshOnly pkgs.jetbrains.jdk;
    binfmt = true;
  };
  environment.variables.JAVA_HOME = "${config.programs.java.package}";

  programs.git = {
    enable = true;
    config = {
      user.name = "DavidArsene";
      user.email = "80218600+DavidArsene@users.noreply.github.com";

      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.line-numbers = true;
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
    };
  };

  services.tailscale.enable = true;
}
