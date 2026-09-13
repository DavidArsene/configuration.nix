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

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
      # generateCompletions = true;
      package = fish; # from newpkgs

      #? Aliases are displayed as-is
      shellAliases = {
        l = "eza -laahg@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
        trenew = "nix-tree --derivation /etc/nixos#nixosConfigurations.(hostname).config.system.build.toplevel";

        nroots = "nix-store --gc --print-roots | rg -v -e /proc -e nix-process";
        nx = "nix --verbose --print-build-logs"; # --log-format bar-with-logs";
        # nix run but with the already downloaded nixpkgs
        nrn = "nx run --override-input nixpkgs nixpkgs";
        # run any command with the ability to write to the nix store
        rw-store = "sudo -E nsenter --env --mount --target (pgrep --oldest nix-daemon)";
      };

      #? Abbreviations are expanded when typed
      shellAbbrs = {
        ",sh" = ", --shell";
        # lmao
        "pretty --set-cursor" =
          "nix repl --file ./%.nix | ${bin colorized-logs "ansi2txt"} | ${bin wl-clipboard-rs "wl-copy"}";

        ngc = "sudo nix-collect-garbage -d";
        ydep = "nix why-depends --all --precise";
        oldcfg = "nrb repl --flake /etc/source";
        # Add custom expression to profile (not just flake#output)
        nprof = "nx profile add --impure --expr 'with import <nixpkgs> { }; ";
        dm = "sudo dmesg --ctime --show-delta --decode";
      };

      interactiveShellInit = "source ${../assets/config.fish}; source ${../assets/alienate.fish}";
    };

    starship = {
      enable = true;
      presets = [
        "nerd-font-symbols"
        "bracketed-segments"
      ];

      # settings = { }; # TODO: declarative

      transientPrompt = {
        enable = true;
        left = "starship module character";
        right = "starship module time";
      };
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = [
        # "--disable-up-arrow"
        # "--disable-ctrl-r"
      ];
      settings = {
        # auto_sync = true;
        dialect = "uk";
        update_check = false;
        sync_frequency = "15m";
        search_mode = "fulltext";
        filter_mode = "global";
        filter_mode_shell_up_key_binding = "host";
        show_numeric_shortcuts = false;
        show_tabs = false; # TODO: ?
        secrets_filter = true;
        enter_accept = true;
        stats = {
          common_subcommands = [
            "git"
            "jj"
            "nix"
            "systemctl"
          ];
          common_prefix = [
            "sudo"
            ","
          ];
          ignored_commands = [ ];
        };
        sync.records = true;
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      flags = [ ];
    };
  };

  # Periodic locatedb update for plocate
  services.locate.enable = true;

  environment = {
    localBinInPath = true;
    systemPackages = [
      fastfetch-unwrapped
      nushell
      pay-respects
      tealdeer
      # terminal-rain
      zoxide

      broot
      fzf
      micro # nano
      ncdu
      superfile

      fish-lsp
      nixd # ! FIXME: test

      fetch # lol 3d spinning logo

      (mylib.mkFreshOnly (fortune.override { withOffensive = true; }))
    ];

    etc."ncdu.conf".text = ''
      --extended
      --exclude-kernfs
      --threads 4
      --show-itemcount
      --show-mtime
      --graph-style eighth-block
      --shared-column unique
      --color dark
    '';
  };
}
