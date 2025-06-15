{...}: {
	nix = {
		channel.enable = false;
		settings = {
			allow-import-from-derivation = false;
			auto-allocate-uids = true;
			auto-optimise-store = true;
			builders-use-substitutes = true;
			experimental-features = ["auto-allocate-uids" "nix-command" "flakes"];
			fallback = false;
			# keep-derivations = false;
			max-jobs = 0; #"auto";
			# show-trace = true;
			use-xdg-base-directories = true;
			warn-dirty = false;
			trusted-substituters = [
				# linux-cachyos
				"https://chaotic-nyx.cachix.org"
			];
			trusted-users = [ "root" "@wheel" ];
		};
	};
	nixpkgs.config.allowUnfree = true;

	environment.localBinInPath = true;
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	system.etc.overlay.mutable = false;
}
