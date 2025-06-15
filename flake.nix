{
	description = "How does one name a system config?";

	inputs = {
		nixpkgs.url = "nixpkgs"; # unstable
		nixos-hw.url = "nixos-hardware";

		chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
		nox.url = "github:madsbv/nix-options-search";

		chaotic.inputs.nixpkgs.follows = "nixpkgs";
		nox.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		self,
		nixpkgs,
		...
	} @ inputs: {
		nixosConfigurations = {
			creeper =
				nixpkgs.lib.nixosSystem {
					system = "aarch64-linux";
					specialArgs = inputs;
					modules = [
						./hardware/oci.nix
						./hosts/creeper.nix
						./modules/default.nix
					];
				};

			legionix =
				nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					specialArgs = inputs;
					modules = [
						./hardware/legionix.nix
						./hosts/legionix.nix
						./modules/desktop.nix
						./modules/default.nix
					];
				};
		};
	};
}
