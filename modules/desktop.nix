{
	kwin-blur,
	pkgs,
	pinned,
	...
}: {
	# Use NetworkManager on desktop for easy Wi-Fi
	networking.networkmanager = {
		enable = true;
		# enableDefaultPlugins = false;
		dns = "systemd-resolved";
		plugins = [];

		wifi.backend = "iwd";
		wifi.powersave = true;
	};

	# disabledModules = [
	# 	"services/desktop-managers/plasma6.nix"
	# ];

	# imports = [
	# 	"${pinpkgs}/nixos/modules/services/desktop-managers/plasma6.nix"
	# ];

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

	# TODO: ?
	# security.rtkit.enable = true;

	environment.systemPackages =
		# KDE
		(with pinned; with pinned.kdePackages; [
				filelight
				kate
				kdeconnect-kde
				yakuake
				kdevelop
				# plasma-sdk

				qownnotes
				qdirstat
				supergfxctl-plasmoid

				# darkly
				# pkgs.nur.repos.shadowrz.klassy-qt6
				kwin-blur.packages.${pkgs.system}.default
			])
		++ (with pkgs; [
				(keystore-explorer.override {
						# TODO: global override
						jdk = pkgs.zulu24;
					})
				(samba.override {
						enableLDAP = true;
						enableProfiling = false;
						enableMDNS = false;
						enableDomainController = true;
						enableRegedit = true;
					})

				# cromite
				# ungoogled-chromium

				amdgpu_top
				fusuma
				pinned.vscodium-fhs
				jetbrains-toolbox
				trayscale
				# waydroid-helper

				# onlyoffice-desktopeditors
				# libreoffice-qt6-fresh-unwrapped

				uefisettings
				uefitool

				btrfs-assistant
				btrfs-heatmap

				lenovo-legion
				s0ix-selftest-tool

				pciutils
				usbtop
				usbutils
			]);

	# GUI Programs
	programs = {
		firefox.enable = true;
		firefox.package = pinned.firefox;
		# firefox.package = pkgs.firefox-devedition-unwrapped;

		kde-pim.enable = false;
		partition-manager.enable = true;
	};

	fonts.packages = with pkgs; [
		nerd-fonts.code-new-roman
		# nerd-fonts.comic-shanns-mono
		nerd-fonts.commit-mono
		# nerd-fonts.jetbrains-mono
		nerd-fonts.symbols-only
	];
}
