{
  mylib,
  newpkgs,
  lib,
  pkgs,
  ...
}:
let
  # Preserve LSP features
  # pkgs = newpkgs;

  theGlobalJava = pkgs.jetbrains.jdk; # -no-jcef;
in
{
  environment.systemPackages = with newpkgs; [
    #* Modern utilities
    bat # ? cat
    btop # ? htop
    curlie # ? curl
    difftastic # ? diff
    doggo # ? dig
    eza # ? ls
    fd # ? find
    # glances
    hexyl # ? xxd
    jujutsu
    jjui # TODO
    kmon
    ripgrep # ? grep
    sd # ? sed
    seccure
    # sequoia-chameleon-gnupg # ? exact gpg replacement
    sequoia-sq # ? gpg reimplementation
    # sequoia-sop # ? stateless opengpg
    # sequoia-wot # ? web of trust something
    xh # ? wget
    zenith # ? htop

    #* Everything else
    _7zz # -rar
    binutils
    copyparty-min # TODO: --help
    (mylib.mkFreshOnly exiftool)
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
    psmisc
    qrencode
    smartmontools
    strace
    strace-analyzer
    # sysdig #? big deps

    jq
    yq-go
    which

    inxi
    dmidecode
    lm_sensors

    clevis
    efivar
    efitools
    efibootmgr
    keyutils
    sbctl
    sbsigntool
  ];

  programs = {
    java = {
      enable = false; # sets variable by shell init, currently babelfish broken
      binfmt = true; # no alternative for this, but meh
      package = lib.mkDefault theGlobalJava;
    };
    # environment.variables.JAVA_HOME = "${theGlobalJava.home}";

    git = {
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
        # core.excludesfile: a global .gitignore
        help.autocorrect = "prompt";
        merge.conflictstyle = "zdiff3";
        url."https://github.com/".insteadOf = "gh:";
      };
    };

    # TODO: scdaemon pcsc-driver= in config
    gnupg.agent = {
      enable = false;
      enableSSHSupport = true;
      settings = {
        # allow-mark-trusted = true;
        default-cache-ttl = 60 * 60 * 3;
        disable-scdaemon = true;
      };
    };
  };
}
