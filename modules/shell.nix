{
  config,
  lib,
  newpkgs,
  mylib,
  ...
}:
let
  pkgs = newpkgs; # LSP
  bin = lib.getExe';
in
with pkgs;
{
  users.defaultUserShell = config.programs.fish.package;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    # generateCompletions = true;
    package = fish; # from newpkgs

    #? Aliases are displayed as-is
    shellAliases = {
      l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
      pamtest = "${lib.getExe pamtester} login $USER authenticate";

      nix = "command nix --verbose --print-build-logs"; # --log-format bar-with-logs";
      # nix run but with the already downloaded nixpkgs
      nrn = "nix run --override-input nixpkgs nixpkgs";
      # run any command with the ability to write to the nix store
      rw-store = "sudo nsenter --env --mount --target (pgrep --oldest nix-daemon)";
    };

    #? Abbreviations are expanded when typed
    shellAbbrs = {
      ltot = "l --total-size";
      ",sh" = ", --shell";
      # lmao
      "pretty --set-cursor" =
        "nix repl --file ./%.nix | ${bin colorized-logs "ansi2txt"} | ${bin wl-clipboard-rs "wl-copy"}";

      ngc = "sudo nix-collect-garbage -d";
      ydep = "nix why-depends --all --precise";
      oldcfg = "nrb repl --flake /etc/source";
      # Add custom expression to profile (not just flake#output)
      "nprof --set-cursor" = "nix profile add --impure --expr 'with import <nixpkgs> { }; %'";
      dm = "sudo dmesg --ctime --show-delta --decode";
    };

    interactiveShellInit = "source ${../assets/config.fish}";
  };

  programs.starship = {
    enable = true;
    package = starship;
    # settings = { }; # TODO: declarative
    transientPrompt.enable = false;
  };

  environment.systemPackages = [
    atuin
    fastfetchMinimal
    nushell
    tealdeer
    zoxide

    broot
    micro # nano
    ncdu
    superfile

    (mylib.mkFreshOnly (fortune.override { withOffensive = true; }))
  ];

  environment.etc."ncdu.conf".text = ''
    --extended
    --exclude-kernfs
    --threads 4
    --show-itemcount
    --show-mtime
    --graph-style eighth-block
    --shared-column unique
    --color dark
  '';
}
