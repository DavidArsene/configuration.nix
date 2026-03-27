{
  mylib,
  mypkgs,
  pkgs,
  newpkgs,
  lib,
  ...
}:
let
  # Preserve LSP features
  pkgs = newpkgs;

  theGlobalJava = pkgs.jetbrains.jdk-no-jcef;
in
{
  environment.systemPackages = with pkgs; [
    #* Modern utilities
    bat # ? cat
    btop # ? htop
    curlie # ? curl
    difftastic # ? diff
    doggo # ? dig
    eza # ? ls
    fd # ? find
    glances
    hexyl # ? xxd
    kmon
    ripgrep # ? grep
    sd # ? sed
    seccure
    sequoia-chameleon-gnupg # ? exact gpg replacement
    sequoia-sq # ? gpg reimplementation
    # sequoia-sop # ? stateless opengpg
    # sequoia-wot # ? web of trust something
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
    pamtester
    plocate
    psmisc
    qrencode
    smartmontools
    strace
    strace-analyzer
    # sysdig #? big deps

    jq
    theGlobalJava
    which

    clevis
    efivar
    efitools
    efibootmgr
    keyutils
    sbctl
    sbsigntool
  ];

  programs.java = {
    enable = false; # sets variable by shell init, currently babelfish broken
    binfmt = true; # no alternative for this, but meh
    package = lib.mkDefault theGlobalJava;
  };
  # environment.variables.JAVA_HOME = "${theGlobalJava.home}";

  programs.git = {
    enable = true;
    config = {
      user.name = "DavidArsene";
      user.email = "80218600+DavidArsene@users.noreply.github.com";

      # core.pager = "delta";
      diff = {
        external = "difft";
        tool = "difftastic";
      };
      # interactive.diffFilter = "delta --color-only";
      # delta.line-numbers = true;
      # delta.navigate = true;
      merge.conflictstyle = "zdiff3";
    };
  };

  # TODO: builder.sh remove-references-to

  # TODO: scdaemon pcsc-driver= in config
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
