{
	config,
	lib,
	pkgs,
	modulesPath,
	...
}: {
	imports = [
		(modulesPath + "/profiles/minimal.nix")
		# (modulesPath + "/profiles/perlless.nix")
	];

	boot.tmp.useTmpfs = true;
	boot.tmp.tmpfsHugeMemoryPages = "within_size";

	#nixpkgs.overlays = [
	#  (final: prev: { stdenv = prev.stdenvNoCC; })
	#];

	networking.firewall.enable = false;

	programs.git.package = pkgs.gitMinimal;
	programs.firefox.wrapperConfig = {
		speechSynthesisSupport = false;
	};

	services.orca.enable = false;
	services.speechd.enable = false;

	environment.plasma6.excludePackages = with pkgs.kdePackages; [
		khelpcenter
		xwaylandvideobridge
	];

	# pkgs.ibus.package = lib.mkForce pkgs.nano;

	# environment.packages = lib.mk

	# Too much
	# fonts.fontconfig.enable = false;
	# xdg.mime.enable = lib.mkForce false;

	# Enable for each system in hardware-configuration.nix
	# after ensuring all required modules are present
	# Also remember VMs
	# boot.initrd.includeDefaultModules = false;
}
