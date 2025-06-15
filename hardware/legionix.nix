{
	lib,
	pkgs,
	specialArgs,
	...
}: {
	imports = [
		specialArgs.nixos-hw.nixosModules.lenovo-legion-16aph8
	];

	boot.initrd = {
		availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "sdhci_pci"]; # "usb_storage""sd_mod"
		luks.devices."luks-root" = {
			bypassWorkqueues = true;
			allowDiscards = true;
			device = "/dev/disk/by-partlabel/NixOS";
		};
	};
	boot.kernelModules = ["kvm-amd"];
	boot.loader.efi.canTouchEfiVariables = true;

	# Fix startup ACPI errors
	boot.kernelParams = ["acpi_osi=\"!Windows2020\""];
	boot.blacklistedKernelModules = ["sp5100_tco"]; # watchdog

	fileSystems."/" = {
		device = "/dev/dm-0"; # Device mapped by LUKS
		fsType = "ext4";
		options = [
			## TODO move to common
			"defaults"
			"noatime"
			"commit=30"
			# "journal_async_commit" only w/o data=ordered
			"lazytime"

			# ext4-specific
			"noquota" # needed?
		];
	};

	fileSystems."/boot" = {
		device = "/dev/disk/by-label/EFIV2";
		fsType = "vfat";
		options = ["fmask=0077" "dmask=0077"];
	};

	hardware = {
		enableAllFirmware = true;

		cpu.amd.ryzen-smu.enable = true;

		amdgpu = {
			amdvlk.supportExperimental.enable = true;
			initrd.enable = false;
			overdrive.enable = true;
			overdrive.ppfeaturemask = "0xffffffff";
		};

		nvidia = {
			# powerManagement.enable = true;
			# powerManagement.finegrained = true;

			# nixos-hardware recommends Sync for AMD
			# prime.sync.enable = false;
			# prime.offload.enable = true;
			# prime.offload.enableOffloadCmd = true;
			# dynamicBoost.enable = true;
		};
		nvidiaOptimus.disable = true;

		usbStorage.manageShutdown = true;
	};

	# 	environment.sessionVariables = {
	#     __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
	#     __GLX_VENDOR_LIBRARY_NAME = "mesa";
	#   };

	powerManagement.enable = true;
	powerManagement.powertop.enable = false;

	systemd.services.bbswitch.enable = lib.mkForce false;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
