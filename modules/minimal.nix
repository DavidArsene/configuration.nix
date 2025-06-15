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
	# boot.tmp.tmpfsSize

	#nixpkgs.overlays = [
	#  (final: prev: { stdenv = prev.stdenvNoCC; })
	#];

	networking.firewall.enable = false;

	# programs.nano.enable = false;
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

	xdg.mime.enable = lib.mkForce false;

	# Should be already provided by hardware-configuration.nix
	# boot.initrd.includeDefaultModules = false;
	# TODO: kbd no work
}
