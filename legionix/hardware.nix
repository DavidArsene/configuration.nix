{
  edge,
  lib,
  pkgs,
  ...
}:
{
  # Lenovo Legion Slim 7 (AMD Gen 8) 16APH8

  boot = rec {
    initrd.availableKernelModules = [ "nvme" ];
    # ++ [ "ata_piix" "sr_mod" ]; # VBox
    # ++ [ "sdhci_acpi" "xhci_pci" ]; # Misc
    # ++ [ "hid_generic" "hid_lenovo" ]; # LUKS in initrd
    initrd.includeDefaultModules = false;

    kernelModules = map (p: p.name) extraModulePackages ++ [
      "kvm-amd"
    ];

    blacklistedKernelModules = [
      "sp5100_tco" # watchdog
      "k10temp" # replaced by zenpower
    ];

    # kernelPackages = edge.callPackage ../modules/cachyos/default.nix { };
    kernelPackages = edge.linuxPackages_zen;

    extraModulePackages = with kernelPackages; [
      bbswitch
      lenovo-legion-module
      zenpower
    ];

    loader.efi.canTouchEfiVariables = true;
    # Fix startup ACPI errors; TODO: find correct year
    kernelParams = [
      ''acpi_osi="!"''
      ''acpi_osi="Windows 2015"''
      ''amd_pstate=active''
    ];
  };

  # pkgs instead of edge for matching QT version
  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];

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
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    #### TODO: ++ BitLocker, key in kwallet???
    # Probably not a good idea to use : in paths
    # "/C:" = {
    #   device = "/dev/disk/by-";
    #   fsType = "ntfs3";
    # };
    # "/D:" = {
    #   device = "/dev/disk/by-";
    #   fsType = "ntfs3";
    # };
  };

  hardware = {
    enableRedistributableFirmware = true;

    cpu.amd.ryzen-smu.enable = true;
    cpu.amd.updateMicrocode = true;

    amdgpu = {
      amdvlk.enable = false;
      amdvlk.supportExperimental.enable = true;
      overdrive.enable = true;
      overdrive.ppfeaturemask = "0xffffffff";
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      # nvidia-smi wakes gpu and doesn't reflect real state

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;

        amdgpuBusId = "PCI:100:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      dynamicBoost.enable = true;
      open = true;

      # package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    graphics.extraPackages32 = lib.mkForce [ ];

    usbStorage.manageShutdown = true;

    firmware = [
      # dmesg | rg "Direct firmware load for"
      # (edge.callPackage ../pkgs/linux-firmware-minimal {

      #   blobs = [
      #     "mediatek/WIFI_RAM_CODE_MT7922_1.bin"
      #     "mediatek/WIFI_MT7922_patch_mcu_1_1_hdr.bin"
      #     "mediatek/BT_RAM_CODE_MT7922_1_1_hdr.bin"

      #     "amdgpu"
      #     # "amdgpu/psp_13_0_4_toc.bin"
      #     # "amdgpu/dcn_3_1_4_dmcub.bin"
      #     # "amdgpu/gc_11_0_1_pfp.bin"
      #     # "amdgpu/sdma_6_0_1.bin"
      #     # "amdgpu/vcn_4_0_2.bin"
      #     # "amdgpu/gc_11_0_1_mes_2.bin"
      #     # "amdgpu/gc_11_0_1_mes.bin"

      #     "nvidia/ad107"
      #     "rtl_nic/rtl8156b-2.fw"
      #   ];
      #   hash = "";
      #   tag = "20250808";
      # })
      pkgs.linux-firmware
    ];
  };

  powerManagement.enable = true;
  systemd.services.powerbottom = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${edge.bash}/bin/bash " + ./powertop.sh;
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Mostly from nixos-hardware
  services = rec {
    # Weird way to enable NVIDIA drivers but ok
    xserver.videoDrivers = [ "nvidia" ];

    # AMD has better battery life with PPD over TLP:
    # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
    power-profiles-daemon.enable = true;

    fstrim.enable = true;

    fwupd = {
      enable = true;
    };

    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = (pkgs.callPackage ../pkgs/libfprint-2-tod1-fpc.nix { });
    }; # don't forget udev!

    udev.packages = [ fprintd.tod.driver ];
  };
}
