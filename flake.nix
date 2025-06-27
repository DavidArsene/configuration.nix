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
						# inputs.nix.nixosModules.default
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
			# creeper =
			# 	mkSystem {
			# 		system = "aarch64-linux";
			# 		hostName = "creeper";
			# 		extraModules = [./hardware/oci.nix];
			# 	};

			legionix =
				mkSystem {
					system = "x86_64-linux";
					hostName = "legionix";
					extraModules = [
						# inputs.chaotic.nixosModules.default

						hardware/legionix.nix
						modules/desktop.nix
					];
				};
		};
	};

	inputs = {
		# Determinate Nix without the useless stuff
		nix.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
		# nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
		nix.inputs.nixpkgs.follows = "nixpkgs"; # what
		nix.inputs.nixpkgs-23-11.follows = "";
		nix.inputs.nixpkgs-regression.follows = "";
		nix.inputs.git-hooks-nix.follows = "";

		## TODO use nixos-unstable;; 41da = weekly 2025-06-17
		nixpkgs.url = "github:NixOS/nixpkgs?ref=41da1e3ea8e23e094e5e3eeb1e6b830468a7399e";
		# nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		nixos-hw.url = "github:NixOS/nixos-hardware";

		treefmt-nix.url = "github:numtide/treefmt-nix";
		treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

		# nox.url = "github:madsbv/nix-options-search";
		# nox.inputs.nixpkgs.follows = "nixpkgs";

		# chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
		# chaotic.inputs = {
		# 	home-manager.follows = "";
		# 	flake-schemas.follows = "";
		# 	jovian.follows = "";
		# not recommended, may invalidate cache
		# 	nixpkgs.follows = "nixpkgs";
		# };

		# kwin-effects-forceblur = {
		# 	url = "github:taj-ny/kwin-effects-forceblur";
		# 	inputs.nixpkgs.follows = "nixpkgs";
		# };
	};

	description = "The Forever Config";
}
