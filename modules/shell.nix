{
	config,
	pkgs,
	...
}: {
	programs.fish = {
		enable = true;
		useBabelfish = true;
		# generateCompletions = true;
	};

	users.defaultUserShell = pkgs.fish;

	# environment.shellAliases = {
	# Aliases are displayed as-is
	programs.fish.shellAliases = {
		l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
		nrb = "nixos-rebuild --no-reexec -v --log-format bar-with-logs --sudo";
		# nix repl with preloaded flake and system config
		ndbg = "nix repl #nixosConfigurations.${config.networking.hostName} .";
	};
	# Abbreviations are expanded when typed
	programs.fish.shellAbbrs = {
		ltot = "l --total-size";

		nrba = "nrb dry-build";
		nrbs = "nrb switch";

		ngc = "sudo nix-collect-garbage -d";
	};

	programs.fish.interactiveShellInit = ''
		# Delete word with CTRL + Backspace
		bind \cH backward-kill-path-component

		function fish_greeting
			fastfetch
		end

		atuin  init fish | source
		zoxide init fish | source
	'';
}
