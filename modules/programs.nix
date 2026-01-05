{
  config,
  mylib,
  # pkgs,
  newpkgs,
  ...
}:
let
  # Preserve LSP features
  pkgs = newpkgs;
in
{
  # TODO: find x86_64-v4 precompileds
  environment.systemPackages = with pkgs; [
    #* Nix
    nix-derivation
    # nix-fast-build
    # nix-forecast
    # nix-inspect
    # nix-locate
    nix-output-monitor
    nix-tree
    # nix-update TODO:
    dix
    manix
    statix
    lon

    #* Modern utilities
    bat # ? cat
    btop # ? htop
    curlie # ? curl
    difftastic # ? diff
    doggo # ? dig
    eza # ? ls
    fd # * everybody hates gnu find
    glances
    hexyl # ? xxd
    kmon
    ripgrep # ? grep
    sd # ? sed
    seccure
    sequoia-chameleon-gnupg # ? exact gpg replacement
    sequoia-sq # ? gpg reimplementation
    sequoia-sqop # ? stateless opengpg
    sequoia-wot # ? web of trust something
    xh # ? wget
    zenith # ? htop

    #* Everything else
    _7zz-rar # ! NOT p7zip
    binutils
    exiftool
    fatrace
    file
    gh
    # imagemagick
    isd
    lshw
    lsof
    mandoc # ? re-add if minimized
    modprobed-db
    psmisc
    qrencode
    smartmontools
    strace
    strace-analyzer
    # sysdig #? big deps

    #* sigh why not already in path
    jq
    which
    wget

    clevis
    efivar
    efitools
    efibootmgr
    keyutils
    sbctl
    sbsigntool
  ];

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

      core.pager = "delta"; # TODO: difftastic
      diff = {
        external = "difft";
        tool = "difftastic";
      };
      interactive.diffFilter = "delta --color-only";
      # delta.line-numbers = true;
      # delta.navigate = true;
      merge.conflictstyle = "zdiff3";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      # allow-mark-trusted = true;
      default-cache-ttl = 60 * 60 * 3;
      # disable-scdaemon = true; # TODO: ?
    };
  };
}
