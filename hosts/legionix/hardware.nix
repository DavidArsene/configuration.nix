{
  lib,
  pkgs,
  mypkgs,
  newpkgs,
  ...
}:
let
  # TODO: https://github.com/garuda-linux/garuda-nix-subsystem/blob/main/internal/modules/base/performance.nix
  # kernel = mypkgs.cachyos-kernel;
  kernel = newpkgs.linuxPackages_latest;
in
{
  # Lenovo Legion Slim 7 (AMD Gen 8) 16APH8

  imports = [
    #    ./bitlocker.nix
    #    mypkgs.fprintd-fpc
  ];

  boot = {
    # TODO: include "nvme" directly in custom kernels
    # TODO: so that initrd can be completely removed.
    initrd.availableKernelModules = [ "nvme" ];
    # ++ [ "ata_piix" "sr_mod" ]; # VBox
    # ++ [ "sdhci_acpi" "xhci_pci" ]; # Misc
    # ++ [ "hid_generic" "hid_lenovo" ]; # LUKS in initrd

    # TODO: test if extraModulePackages are auto loaded
    kernelModules = [ "kvm-amd" ];

    blacklistedKernelModules = [
      "sp5100_tco" # watchdog
      "k10temp" # replaced by zenpower
    ];

    kernelPackages = kernel;

    extraModulePackages = with kernel; [
      bbswitch
      cpupower
      # lenovo-legion-module FIXME:
      zenpower
    ];

    # Fix startup ACPI errors; TODO: find correct year
    kernelParams = [
      # ''acpi_osi="!"''
      ''acpi_osi="Windows 2021"''

      ''amd_pstate=active''
    ];

    loader.efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    # lenovo-legion FIXME:
    nvidia-system-monitor-qt
    ryzenadj
    ryzen-monitor-ng
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
  };

  hardware = {
    cpu.amd.ryzen-smu.enable = true;
    cpu.amd.updateMicrocode = true;

    amdgpu = {
      overdrive.enable = true;
      overdrive.ppfeaturemask = "0xffffffff";
    };

    nvidia = {
      dynamicBoost.enable = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      # ! nvidia-smi wakes gpu and doesn't reflect real state

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
          offloadCmdMainProgram = "prime-run";
        };
        amdgpuBusId = "PCI:100:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      open = true;
      package = kernel.nvidiaPackages.beta.override {
        disable32Bit = true; # TODO: add to minimal.nix
      };
    };

    usbStorage.manageShutdown = true;

    firmware = [
      # dmesg | rg "Direct firmware load for"
      (mypkgs.firmware-minimal.override {

        # ! Don't forget to change hash
        blobs = [
          "mediatek/WIFI_RAM_CODE_MT7922_*.bin"
          "mediatek/WIFI_MT7922_patch_mcu_*.bin"
          "mediatek/BT_RAM_CODE_MT7922_*.bin"

          # https://docs.kernel.org/gpu/amdgpu/driver-core.html
          # https://docs.kernel.org/gpu/amdgpu/amdgpu-glossary.html
          # https://docs.kernel.org/gpu/amdgpu/display/dc-glossary.html
          "amdgpu/psp_*.bin" # Platform Security Processor
          "amdgpu/dcn_*_dmcub.bin" # Display Controller Next
          "amdgpu/gc_*.bin" # Graphics and Compute
          "amdgpu/sdma_*.bin" # System DMA
          "amdgpu/vcn_*.bin" # Video Core Next

          # "amdgpu/psp_13_0_4_toc.bin"
          # "amdgpu/dcn_3_1_4_dmcub.bin"
          # "amdgpu/gc_11_0_1_pfp.bin"
          # "amdgpu/sdma_6_0_1.bin"
          # "amdgpu/vcn_4_0_2.bin"
          # "amdgpu/gc_11_0_1_mes_2.bin"
          # "amdgpu/gc_11_0_1_mes.bin"

          "nvidia/ad102/"
          "rtl_nic/rtl8156b-*.fw"

          # https://gitlab.com/kernel-firmware/linux-firmware/-/commit/2b6dd0c8
          "cirrus/cs35l41-dsp1-spk-prot-17aa38b4-spkid*-*0.bin" # spkid{0,1}-{l,r}0
          "cirrus/cs35l41/v6.61.1/halo_cspl_RAM_revB2_29.63.1.wmfw"
        ];

        extraSetup = ''
          mv -v nvidia/ad102/ nvidia/ad107/

          mv -v cirrus/cs35l41/v*/*.wmfw cirrus/cs35l41-dsp1-spk-prot-17aa38b4.wmfw
          ${pkgs.util-linux}/bin/rename -v 17aa38b4 17aa38b7 cirrus/*
        '';

        hash = "sha256-nh46WgxTbYTrz04IgJrV8pJozJAofFF7VD+75iolzwk=";
        tag = "20251125";
      })
    ];
  };

  powerManagement.enable = true;
  systemd.services.powerbottom = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash " + ./powertop.sh;
    };
    wantedBy = [ "multi-user.target" ];
  };

  #* Mostly from nixos-hardware
  services = {
    #* Weird way to enable NVIDIA drivers but ok
    xserver.videoDrivers = [ "nvidia" ];

    #* > AMD has better battery life with PPD over TLP:
    # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
    power-profiles-daemon.enable = true;
    tlp.enable = false; # TODO: TRY
    # TODO: ALSO THIS
    # echo powersupersave > /sys/module/pcie_aspm/parameters/policy
    # ^^^ what are those
    # appears to change `lspci -vv | grep 'ASPM.*abled;'`

    fstrim.enable = true;

    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };

  };
}
