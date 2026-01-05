{ config, newpkgs, ... }:
let
  pkgs = newpkgs; # LSP
in
{
  users.defaultUserShell = config.programs.fish.package;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    # generateCompletions = true;
    package = newpkgs.fish;

    #? Aliases are displayed as-is
    shellAliases = {
      l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
      wget = "wget -q --show-progress";

      nix = "nix --verbose --log-format bar-with-logs";
      nrb = "STC_DEBUG=1 STC_DISPLAY_ALL_UNITS=1 nixos-rebuild --sudo --fast --verbose";
      nrbdev = "nrb --override-input mypkgs ~/.nix/mypkgs.nix --override-input minimal ~/.nix/minimal.nix";
      rw-store = "sudo nsenter --env --mount --target (pgrep --oldest nix-daemon)";
    };

    #? Abbreviations are expanded when typed
    shellAbbrs = {
      ltot = "l --total-size";

      dry = "nrbdev dry-build";
      switch = "nrbdev switch --log-format internal-json &| nom --json";
      test = "nrbdev test --log-format internal-json &| nom --json";

      ngc = "sudo nix-collect-garbage -d";
      ydep = "nix why-depends --all --precise";
      oldcfg = "nrb repl --flake /etc/source";
    };

    interactiveShellInit = "source ${../assets/config.fish}";
  };

  programs.starship = {
    enable = true;
    package = newpkgs.starship;
    # settings = { }; # TODO: declarative
    transientPrompt.enable = false;
  };

  environment.systemPackages = with pkgs; [
    atuin
    fastfetchMinimal
    nushell
    tealdeer
    zoxide

    broot
    micro # nano
    ncdu
    superfile

    fortune
    # (fortune.override { withOffensive = true; })
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
