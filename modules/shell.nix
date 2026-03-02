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
  nom = "--log-format internal-json &| nom --json";
in
with pkgs;
{
  users.defaultUserShell = config.programs.fish.package;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    # generateCompletions = true;
    package = fish;

    #? Aliases are displayed as-is
    shellAliases = {
      l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
      pamtest = "${lib.getExe pamtester} login $USER authenticate";

      nix = "command nix --verbose --print-build-logs"; # --log-format bar-with-logs";
      # nixos-rebuild that also fixes the annoying "Path /tmp is world-writable" error
      # https://github.com/NixOS/nix/issues/13701 - fix: remove w for a; sudo chown -v root:users /tmp;
      nrb = "sudo chmod -v o-w /tmp; nixos-rebuild --sudo --no-reexec";
      # override child flakes for local development
      # TODO: find another way that works with the eval cache
      nrbdev = "nrb --override-input mypkgs ~/.nix/mypkgs.nix --override-input minimal ~/.nix/minimal.nix";
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

      dry = "nrbdev dry-build --print-build-logs";
      switch = "nrbdev switch ${nom}";
      try = "nrbdev test ${nom}";

      ngc = "sudo nix-collect-garbage -d";
      ydep = "nix why-depends --all --precise";
      oldcfg = "nrb repl --flake /etc/source";
      # Add custom expression to profile (not just flake#output)
      "nprof --set-cursor" = "nix profile add --impure --expr 'with import <nixpkgs> { }; %'";
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
