{
	config,
	pkgs,
	...
}: {
	# Use NetworkManager on desktop for easy Wi-Fi
	networking.networkmanager = {
		enable = true;
		enableDefaultPlugins = false;
		dns = "systemd-resolved";

		wifi.backend = "iwd";
		wifi.powersave = true;
	};

	services = {
		# xserver.enable = true;

		displayManager.sddm.enable = true;
		displayManager.autoLogin.enable = true;
		displayManager.autoLogin.user = config.users.flakeGlobal;

		desktopManager.plasma6.enable = true;
		desktopManager.plasma6.enableQt5Integration = false;

		# supergfxd.enable = true;
	};

	# Recommended by Darkly
	# KDE Settings will not work anymore; use Qt6 Settings
	qt.platformTheme = "qt5ct";

	security.rtkit.enable = true;

	environment.systemPackages = with pkgs; [
		# KDE
		kdePackages.kate
		kdePackages.filelight
		kdePackages.yakuake
		qdirstat
		supergfxctl-plasmoid
		darkly
		# specialArgs.kwin-effects-forceblur.packages.${pkgs.system}.default

		# Other apps
		amdgpu_top
		waydroid-helper
		vscodium-fhs
		trayscale
		# onlyoffice-desktopeditors
		# libreoffice-qt6-fresh-unwrapped

		# CLI
		lenovo-legion
		s0ix-selftest-tool

		# stdenv
	];

	# GUI Programs
	programs = {
		firefox.enable = true;
		# firefox.package = pkgs.firefox-devedition-unwrapped;

		kde-pim.enable = false;
		partition-manager.enable = true;
	};

	fonts.packages = with pkgs; [
		nerd-fonts.code-new-roman
		nerd-fonts.comic-shanns-mono
		nerd-fonts.commit-mono
		# nerd-fonts.jetbrains-mono
		nerd-fonts.symbols-only
	];
}
