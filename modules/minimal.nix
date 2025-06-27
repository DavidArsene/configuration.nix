{
	config,
	lib,
	pkgs,
	...
}: {
	## <profiles/minimal.nix>
	# Remember to update from time to time

	documentation = {
		enable = lib.mkForce false;
		doc.enable = lib.mkForce false;
		info.enable = lib.mkForce false;
		man.enable = lib.mkForce false;
		man.generateCaches = lib.mkForce false;
		# TODO: doesn't appear to work
		man.man-db.skipPackages = lib.mkForce config.environment.systemPackages;
		nixos.enable = lib.mkForce false;
	};

	environment = {
		defaultPackages = lib.mkForce [];
		stub-ld.enable = lib.mkDefault false;
	};

	programs = {
		# -_- trying to avoid Perl is futile
		less.lessopen = lib.mkForce null;
		command-not-found.enable = lib.mkForce false;
		# TODO: update nixpkgs
		# fish.generateCompletions = lib.mkForce false;
	};

	services = {
		# TODO: check needed
		logrotate.enable = lib.mkDefault false;
		# TODO: use for BitLocker?
		udisks2.enable = lib.mkDefault false;
	};

	xdg = {
		autostart.enable = lib.mkDefault false;
		icons.enable = lib.mkDefault false;
		mime.enable = lib.mkDefault false;
		sounds.enable = lib.mkDefault false;
	};

	## </profiles/minimal.nix>

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
		# aurorae
		# kwin-x11 TODO: NIXPKGS NEW
		khelpcenter
		ffmpegthumbs
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

	#TODO: ensure-all-wrappers-paths-exist
}
