{
	outputs = {
		nixpkgs,
		pinpkgs,
		...
	} @ inputs: let
		inherit (nixpkgs) lib;
		mkSystem = {
			system,
			hostName,
			extraModules,
		}:
			lib.nixosSystem {
				specialArgs =
					inputs
					// {
						modulesPath = "${nixpkgs}/nixos/modules";
						inherit pinpkgs;
						pinned =
							import pinpkgs {
								inherit system;
								config.allowUnfree = true;
							};
					};
				modules =
					extraModules
					++ [
						./hosts/${hostName}.nix
						modules/common.nix
						modules/nix.nix
						modules/programs.nix
						modules/shell.nix

						modules/minimal.nix
						# pa-pa-para
						modules/pa-ra-no-i-a.nix

						inputs.nur.modules.nixos.default
						{
							config.networking.hostName = hostName;
							config.nixpkgs.hostPlatform = system;

							options.users.flakeGlobal =
								lib.mkOption {
									type = lib.types.str;
									default = "david";
								};
						}
						# ({pinned, ...}: {
						# 		nixpkgs.overlays = [
						# 			(final: prev: {
						# 					kde = pinned.kde;
						# 					applications.kde = pinned.applications.kde;
						# 					kdePackages = pinned.kdePackages;
						# 					libsForQt6 = pinned.libsForQt6;
						# 					plasma-desktop = pinned.plasma-desktop;
						# 				})
						# 		];
						# 	})
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

		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		pinpkgs.url = "github:NixOS/nixpkgs/30e2e285";

		nur.url = "github:nix-community/NUR";
		nur.inputs.nixpkgs.follows = "nixpkgs";

		treefmt-nix.url = "github:numtide/treefmt-nix";
		treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

		# nox.url = "github:madsbv/nix-options-search";
		# nox.inputs.nixpkgs.follows = "nixpkgs";

		kwin-blur.url = "github:taj-ny/kwin-effects-forceblur";
		kwin-blur.inputs.nixpkgs.follows = "nixpkgs";
	};
}
