{pkgs, ...}: {
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
		displayManager.autoLogin.user = "david";

		desktopManager.plasma6.enable = true;
		desktopManager.plasma6.enableQt5Integration = false;

		# graphical-desktop.nix also enables sound

		# supergfxd.enable = true;
	};

	security.rtkit.enable = true;

	environment.systemPackages = with pkgs; [
		# KDE
		kdePackages.kate
		kdePackages.filelight
		qdirstat
		supergfxctl-plasmoid

		# Other apps
		amdgpu_top
		waydroid-helper
		vscodium-fhs

		# CLI
		lenovo-legion
		s0ix-selftest-tool

		# stdenv
	];

	# GUI Programs
	programs = {
		firefox.enable = true;
		kde-pim.enable = false;
		partition-manager.enable = true;
	};
}
