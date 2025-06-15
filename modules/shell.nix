{config, ...}: {
	environment.shellAliases = {
		l = "eza";
		pls = "sudo !!";

		# TODO: config path
		nrbs = "nixos-rebuild switch --fast -v --log-format bar-with-logs --flake ~/nixconfig";
		ndbg = "nix repl $PWD#nixosConfigurations.${config.networking.hostName}";
		nxgc = "nix-collect-garbage -d";
	};
}
