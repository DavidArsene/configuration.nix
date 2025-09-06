{
  edge,
  config,
  pkgs,
  ...
}:
{
  # TODO: find x86_64-v4 precompileds
  environment.systemPackages =
    (with edge; [
      # Nix
      nix-tree
      nixd
      nixfmt
      nix-forecast
      # nix-du
      # nix-fast-build
      # nix-inspect
      # nix-locate
      nvd

      # Modern utilities
      bat # cat
      btop # htop
      curlie # curl
      delta # diff
      eza # ls
      fd # everybody hates gnu find
      glances
      ripgrep # grep
      xh # wget

      # Everything else
      binutils
      fatrace
      file
      gh
      imagemagick
      lshw
      lsof
      modprobed-db
      p7zip-rar
      psmisc
      qrencode
      smartmontools
      strace
      strace-analyzer
      sysdig
      tinyxxd
      which
      wget # sigh why not in path

      efivar
      efitools
      efibootmgr
      sbctl
      sbsigntool

      rustup
    ])
    ++ (with pkgs; [
      python3 # TODO: move to dev.nix
      (callPackage ../pkgs/powertop.nix { })
    ]);

  programs.java = {
    enable = false; # TODO: difference between manually setting JAVA_HOME?
    # package = pkgs.callPackage ../pkgs/zing.nix { };
    binfmt = true;
  };
  # environment.variables.JAVA_HOME = "${config.programs.java.package}";

  programs.git = {
    enable = true;
    config = {
      # TODO: cannot be read from VSCode FSHenv
      user.name = "DavidArsene";
      user.email = "80218600+DavidArsene@users.noreply.github.com";

      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.line-numbers = true;
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
    };
  };

  programs.nh = {
    enable = true;
    flake = config.environment.etc."nixos".source;
  };

  services.tailscale.enable = true;
}
