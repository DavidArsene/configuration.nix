{
	config,
	pkgs,
	...
}: {
	users.defaultUserShell = pkgs.fish;

	# environment.shellAliases = {
	# Aliases are displayed as-is
	programs.fish.shellAliases = {
		l = "eza -lah@MF --color-scale --icons --hyperlink --group-directories-first --time-style relative";
		nrb = "nixos-rebuild --no-reexec -v --log-format bar-with-logs";
	};
	# Abbreviations are expanded at runtime
	programs.fish.shellAbbrs = {
		ltot = "l --total-size";

		nrba = "nrb dry-build";
		nrbs = "nrb --sudo switch";

		# nix repl with preloaded flake and system config
		ndbg = "nix repl $PWD#nixosConfigurations.${config.networking.hostName} $PWD";
		ngc = "sudo nix-collect-garbage -d";
	};
}
