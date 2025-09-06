{
  config,
  edge,
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
      # nix repl with preloaded flake and system config
      ndbg = "nix repl #nixosConfigurations.${config.networking.hostName} .";
      wget = "wget -q --show-progress";
    };

    # Abbreviations are expanded when typed
    shellAbbrs = {
      ltot = "l --total-size";
      ngc = "sudo nix-collect-garbage -d";
    };

    interactiveShellInit = ''
      		# Delete word with CTRL + Backspace
      		bind \cH backward-kill-path-component

      		function fish_greeting
      			fastfetch
      		end

      		atuin  init fish | source
      		zoxide init fish | source
      	'';
  };

  programs.starship = {
    enable = true;
    package = edge.starship;
    # settings = { }; # TODO: declarative
    transientPrompt.enable = false;
  };

  environment.systemPackages = with edge; [
    atuin
    fastfetchMinimal
    nushell
    zoxide

    (fortune.override { withOffensive = true; })
  ];
}
