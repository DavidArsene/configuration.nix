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
		# ata_piix and sr_mod were added on VBox
		availableKernelModules = ["nvme" "xhci_pci" "usbhid" "sdhci_pci" "hid_generic" "hid_lenovo"];
		includeDefaultModules = false;
		luks.devices."luks-root" = {
			bypassWorkqueues = true;
			allowDiscards = true;
			device = "/dev/disk/by-partlabel/NixOS";
		};
	};
	boot.kernelModules = ["kvm-amd"];
	boot.loader.efi.canTouchEfiVariables = true;

	# Fix startup ACPI errors - nope
	boot.kernelParams = ["acpi_osi=\"Linux\""];
	# boot.blacklistedKernelModules = ["sp5100_tco"]; # watchdog

	fileSystems."/" = {
		device = "/dev/dm-0"; # LUKS mapping
		fsType = "ext4";
		options = [
			## TODO move to common
			"defaults"
			"noatime"
			"commit=30"
			# "journal_async_commit"
			# only w/o data=ordered
			"lazytime"
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
			# package = null;#pkgs.linuxPackages_cachyos.nvidia_x11;
		};
		# nvidiaOptimus.disable = true;

		usbStorage.manageShutdown = true;
	};

	# 	environment.sessionVariables = {
	#     __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
	#     __GLX_VENDOR_LIBRARY_NAME = "mesa";
	#   };

	powerManagement.enable = true;
	# TODO: make this static
	powerManagement.powertop.enable = true;
	# /usb/devices/1-5/power/control on not auto - keyboard

	# boot.kernelPackages = pkgs.linuxPackages_cachyos;#specialArgs.chaotic.unrestrictedPackages.x86_64-linux.linuxPackages_cachyos;

	# Manual blacklist to abvoid nvidiaOptimus.disable which enables bbswitch
	boot.blacklistedKernelModules = [
		"sp5100_tco" # watchdog
		"nouveau"
		"nvidia"
		"nvidiafb"
		"nvidia-drm"
		"nvidia-modeset"
	];
}
