{...}: {
	virtualisation.virtualbox.guest.enable = false; # wtf 2GB
	virtualisation.waydroid.enable = true;

	boot.loader.systemd-boot = {
		enable = true;
		consoleMode = "max";
		# graceful = true;
		configurationLimit = 7;
		edk2-uefi-shell.enable = true;
		netbootxyz.enable = true;
		windows."11" = {
			title = "Windows 11";
			efiDeviceHandle = "HD0b";
			sortKey = "hahaha";
		};
	};

	# system.nixos.label = "NixOS 25.11 Unstable";
	# system.nixos.version = "25.11 Unstable";
	# system.nixos.codeName = "-";
	# system.nixos.revision = "";
	system.stateVersion = "25.11"; # Did you read the comment?
}
