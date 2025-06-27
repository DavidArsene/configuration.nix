{
	config,
	lib,
	pkgs,
	...
}: {
	### TODO: Add env NIXOS_CONFIG
	boot.kernelParams = [
		"mitigations=off"
		"nowatchdog"
		# Disable SSD power-saving for lower latency
		# "nvme_core.default_ps_max_latency_us=0"
		# Debatable results
		# "preempt=full"
		"iommu.passthrough=1" # TODO: Default?
		"iommu=pt" # TODO: ^^^
	];
	boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

	systemd.extraConfig = "StatusUnitFormat=combined";

	time.timeZone = "Europe/Bucharest";

	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_US.UTF-8";
		LC_IDENTIFICATION = "ro_RO.UTF-8";
		LC_MEASUREMENT = "C.UTF-8";
		LC_MONETARY = "ro_RO.UTF-8";
		LC_NAME = "ro_RO.UTF-8";
		LC_NUMERIC = "ro_RO.UTF-8";
		LC_PAPER = "C.UTF-8";
		LC_TELEPHONE = "ro_RO.UTF-8";
		LC_TIME = "C.UTF-8";
	};
	i18n.supportedLocales = [
		"C.UTF-8/UTF-8"
		"en_US.UTF-8/UTF-8"
		"en_US/ISO-8859-1"
		"ro_RO.UTF-8/UTF-8"
		"ro_RO/ISO-8859-2"
	];
	i18n.inputMethod.enableGtk3 = false;

	users.users.${config.users.flakeGlobal} = {
		isNormalUser = true;
		description = "David";
		extraGroups = ["networkmanager" "wheel"];
		hashedPassword = "$y$j9T$qziosG8H1ZEuu7FMixgtk0$4aTF5xoTyg1MzcH2yUcb1/L21w3IigoYdId.vEdLnA9";
	};
	users.mutableUsers = false;

	# Download more RAM!
	zramSwap = {
		enable = true;
		priority = 100;
		memoryPercent = 66;
	};

	security.doas.enable = true;
	# security.sudo.enable = false;
	security.sudo.wheelNeedsPassword = false;
	security.doas.wheelNeedsPassword = false;
	
	environment.etc."doas.conf".text = lib.mkForce ''
		permit nopass nolog keepenv root :wheel
	'';
	# security.pam.services

	# TODO move
	# boot.kernel.sysctl = {
	# 	"centisex"
	# };
}
