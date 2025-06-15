{...}: {
	imports = [
		./common.nix
		./nix.nix
		./programs.nix
		./shell.nix

		# run minimal last to override everyone else
		# this should be the case in flake.nix as well
		./minimal.nix
	];
}
