{
	chaotic,
	config,
	pkgs,
	...
}: {
	# Lenovo Legion Slim 7 (AMD Gen 8) 16APH8

	boot = {
		# ata_piix and sr_mod were added on VBox
		initrd.availableKernelModules = ["nvme"]; # "ata_piix" "sdhci_pci" "sr_mod" "xhci_pci"]; # "usbhid" "hid_generic" "hid_lenovo"];
		initrd.includeDefaultModules = false;

		kernelModules = ["kvm-amd"]; # "zenpower"];
		loader.efi.canTouchEfiVariables = true;

		# Fix startup ACPI errors; 2021 kills touchpad
		# amd_pstate from common/cpu/amd/pstate.nix
		kernelParams = [''acpi_osi="!"'' ''acpi_osi="Windows 2015"'' "amd_pstate=active"];

		# kernelPackages = chaotic.unrestrictedPackages.x86_64-linux.linuxPackages_cachyos;

		# Manual blacklist to abvoid nvidiaOptimus.disable which enables bbswitch
		blacklistedKernelModules = [
			"sp5100_tco" # watchdog
			"nouveau"
			"nvidia"
			"nvidiafb"
			"nvidia-drm"
			"nvidia-modeset"
			# common/cpu/amd/zenpower.nix
			# "k10temp"
		];

		# extraModulePackages = [config.boot.kernelPackages.zenpower];
	};
	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/NixOS";
			fsType = "btrfs";
			options = [
				"noacl"
				"noatime"
				"compress=zstd:3"
			];
		};
		"/home" = {
			device = "/dev/disk/by-label/Home";
			fsType = "ext4";
			options = [
				"defaults"
				"noatime"
				"commit=30"
				"lazytime"
			];
		};
		"/boot" = {
			device = "/dev/disk/by-label/EFIV2";
			fsType = "vfat";
			options = ["fmask=0077" "dmask=0077"];
		};
	};

	hardware = {
		enableRedistributableFirmware = true;

		cpu.amd.ryzen-smu.enable = true;
		# common/cpu/amd/default.nix
		cpu.amd.updateMicrocode = true;

		amdgpu = {
			amdvlk.supportExperimental.enable = true;
			overdrive.enable = true;
			overdrive.ppfeaturemask = "0xffffffff";
		};

		# TODO
		# graphics.enable = true;
		# graphics.enable32Bit = true;

		# nvidia = {
		# <nixos-hardware>
		# modesetting.enable = lib.mkDefault true;
		# powerManagement.enable = lib.mkDefault false;
		# powerManagement.finegrained = lib.mkDefault false;
		# prime = {
		# sync.enable = lib.mkDefault true;
		# amdgpuBusId = "PCI:5:0:0";
		# nvidiaBusId = "PCI:1:0:0";
		# };
		# </nixos-hardware>

		# nixos-hardware recommends Sync for AMD
		# prime.sync.enable = false;
		# prime.offload.enable = true;
		# prime.offload.enableOffloadCmd = true;
		# dynamicBoost.enable = true;
		# package = null; # pkgs.linuxPackages_cachyos.nvidia_x11;
		# open = true;
		# };
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

	# <nixos-hardware>
	# Avoid issues with modesetting causing blank screen
	services.xserver.videoDrivers = ["modesetting"]; # "nvidia"];

	# AMD has better battery life with PPD over TLP:
	# https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
	services.power-profiles-daemon.enable = true;

	services.fstrim.enable = true;
	# </nixos-hardware>

	services.fprintd = {
		enable = true;
		tod = {
			enable = true;
			driver = pkgs.callPackage ../modules/libfprint-2-tod1-fpc.nix { };
		};
	};

	# services.udev.packages = [config.services.fprintd.tod.driver];
}
