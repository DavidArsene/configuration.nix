{
	config,
	pkgs,
	specialArgs,
	...
}: {
	nix = {
		channel.enable = false;
		settings = {
			accept-flake-config = false;
			allow-import-from-derivation = false;
			auto-allocate-uids = true;
			auto-optimise-store = true;
			builders-use-substitutes = true;
			experimental-features = ["auto-allocate-uids" "nix-command" "flakes"];
			flake-registry = "";
			fallback = false;
			# keep-derivations = false;
			# disables builds but that means it can't build the system
			# max-jobs = 0;
			# show-trace = true;
			use-xdg-base-directories = true;
			warn-dirty = false;
			trusted-substituters = [
				# Nix Community
				# "https://nix-community.cachix.org"
				# linux-cachyos
				# "https://chaotic-nyx.cachix.org"
				# DetSys Nix
				"https://install.determinate.systems"
			];
			trusted-users = ["@wheel"];

			lazy-trees = true;
		}; # DetSys Nix  ^ and v
		package = specialArgs.nix.packages.${pkgs.system}.default;
		registry.nixpkgs.flake = specialArgs.nixpkgs;
	};
	nixpkgs.config.allowUnfree = true;
	# nixpkgs.flake.setNixPath = false; # TODO:
	# nixpkgs.flake.setFlakeRegistry = false;

	environment.etc."nixos" = {
		source = "/home/${config.users.flakeGlobal}/nixconfig/";
		target = "nixos";
		mode = "symlink";
	};

	environment.localBinInPath = true;
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	system.etc.overlay.mutable = false;
}
