{
	kwin-blur,
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
		# displayManager.autoLogin.enable = true;
		# displayManager.autoLogin.user = config.users.flakeGlobal;

		desktopManager.plasma6.enable = true;
		desktopManager.plasma6.enableQt5Integration = false;

		# supergfxd.enable = true;
	};

	# Recommended by Darkly
	# KDE Settings will not work anymore; use `Qt6 Settings`
	# qt.platformTheme = "qt5ct";
	# qt.style = "kvantum";

	security.rtkit.enable = true;

	environment.systemPackages = with pkgs; [
		# KDE
		kdePackages.filelight
		kdePackages.kate
		kdePackages.kdeconnect-kde
		kdePackages.yakuake
		kdePackages.kdevelop
		# klassy
		qdirstat
		supergfxctl-plasmoid
		darkly
		# kwin-blur.packages.${pkgs.system}.default
		qownnotes

		fusuma
		(keystore-explorer.override {
			# TODO: global override
			jdk = pkgs.zulu24;
		})
		# (samba.override {})

		# Other apps
		# cromite
		ungoogled-chromium
		amdgpu_top
		# waydroid-helper
		vscodium-fhs
		trayscale
		# onlyoffice-desktopeditors
		# libreoffice-qt6-fresh-unwrapped
		uefisettings
		uefitool

		# CLI
		lenovo-legion
		s0ix-selftest-tool

		pciutils
		usbtop
		usbutils

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
