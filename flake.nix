{
	outputs = {nixpkgs, ...} @ inputs: let
		inherit (nixpkgs) lib;
		mkSystem = {
			system,
			hostName,
			extraModules,
		}:
			lib.nixosSystem {
				# inherit system;
				specialArgs = inputs;
				# // { modulesPath = "${nixpkgs}/nixos/modules"; };
				modules =
					extraModules
					++ [
						{
							config.networking.hostName = hostName;
							config.nixpkgs.hostPlatform = system;

							options.users.flakeGlobal =
								lib.mkOption {
									type = lib.types.str;
									default = "david";
								};
						}
						./hosts/${hostName}.nix
						modules/common.nix
						modules/nix.nix
						modules/programs.nix
						modules/shell.nix

						modules/minimal.nix
						# pa-pa-para
						modules/pa-ra-no-i-a.nix
					];
			};
	in {
		nixosConfigurations = {
			creeper =
				mkSystem {
					system = "aarch64-linux";
					hostName = "creeper";
					extraModules = [./hardware/oci.nix];
				};

			legionix =
				mkSystem {
					system = "x86_64-linux";
					hostName = "legionix";
					extraModules = [
						hardware/legionix.nix
						modules/desktop.nix
						modules/games.nix
					];
				};
		};
	};

	# formatter =

	inputs = {
		# Determinate Nix without the useless stuff
		# nix.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
		# nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
		# nix.inputs.nixpkgs.follows = "nixpkgs"; # what
		# nix.inputs.nixpkgs-23-11.follows = "";
		# nix.inputs.nixpkgs-regression.follows = "";
		# nix.inputs.git-hooks-nix.follows = "";

		## TO-DO use nixos-unstable;; 41da = weekly 2025-06-17
		nixpkgs.url = "github:NixOS/nixpkgs?ref=30e2e285";
		# nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		treefmt-nix.url = "github:numtide/treefmt-nix";
		treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

		# nox.url = "github:madsbv/nix-options-search";
		# nox.inputs.nixpkgs.follows = "nixpkgs";

		chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
		chaotic.inputs = {
			home-manager.follows = "";
			flake-schemas.follows = "";
			jovian.follows = "";
			# not recommended, may invalidate cache
			# nixpkgs.follows = "nixpkgs";
		};

		# kwin-blur = {
		# 	url = "github:taj-ny/kwin-effects-forceblur";
		# 	inputs.nixpkgs.follows = "nixpkgs";
		# };
	};
}
