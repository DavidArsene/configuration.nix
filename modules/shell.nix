{
  config,
  edge ? pkgs,
  pkgs,
  ...
}:
{
  users.defaultUserShell = edge.fish;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    # generateCompletions = true;
    package = config.users.defaultUserShell;

    # Aliases are displayed as-is
    shellAliases = {
      l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
      wget = "wget -q --show-progress";

      rw-store = "sudo nsenter --mount --target (pgrep --oldest nix-daemon)";
    };

    # Abbreviations are expanded when typed
    shellAbbrs = {
      ltot = "l --total-size";
      ngc = "sudo nix-collect-garbage -d";

      # nix repl with preloaded flake and system config
      oldcfg = "nix repl /etc/source#nixosConfigurations.(hostname)";
      newcfg = "nix repl /etc/nixos/#nixosConfigurations.(hostname)";
    };

    interactiveShellInit = ./config.fish;
  };

  programs.starship = {
    enable = true;
    package = edge.starship;
    # settings = { }; # TODO: declarative
    transientPrompt.enable = false;
  };

  environment.systemPackages = with pkgs; [
    atuin
    fastfetchMinimal
    # nushell
    zoxide

    # (fortune.override { withOffensive = true; })
  ];
}
