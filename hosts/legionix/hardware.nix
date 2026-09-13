{
  lib,
  pkgs,
  mypkgs,
  ...
}:
let
  # TODO: https://github.com/garuda-linux/garuda-nix-subsystem/blob/main/internal/modules/base/performance.nix
  # kernel = mypkgs.cachyos-kernel;

  kernel = pkgs.linuxPackages_latest
  #  .extend (
  #    final: prev: {
  #      lenovo-legion-module = prev.lenovo-legion-module.overrideAttrs { inherit (mypkgs.lll) src; };
  #    }
  #  )
  ;
in
{
  # Lenovo Legion Slim 7 (AMD Gen 8) 16APH8

  boot = {
    # TODO: include "nvme" directly in custom kernels
    # TODO: so that initrd can be completely removed.
    initrd.availableKernelModules = [ "nvme" ];

    kernelPackages = kernel;

    extraModulePackages = with kernel; [
      cpupower
      lenovo-legion-module
    ];

    kernelParams = [
      # TODO: look for debug messages in dmesg
      "acpi_enforce_resources=lax"

      "acpi_osi=!"
      ''acpi_osi="Windows 2015"''

      # "apic=verbose"
      "console_msg_format=syslog"
      # "hpet=verbose"
      # "ignore_loglevel"
      "lsm.debug=1"

      "audit=off"
      "bgrt_disable"

      # TODO: perf?
      # "pci=pci_bus_safe"
      "pnp.debug=1" # CONFIG_PNP_DEBUG_MESSAGES
      # TODO: thermal gov bang bang
    ];
  };

  environment.systemPackages = with pkgs; [
    #! mypkgs.lll
    lenovo-legion
    # nvidia-system-monitor-qt
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
        # "lazytime"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFIV2";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  # TODO: useful?
  comment.services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/wakeup}="disabled"
  '';

  hardware = {
    nvidia.prime.amdgpuBusId = "PCI:101@0:0:0"; # lspci = (@0) 65:00.0

    firmware = [
      # dmesg | rg "Direct firmware load for"
      (mypkgs.firmware-minimal.override {

        # ! Don't forget to change hash
        blobs = [
          "mediatek/WIFI_RAM_CODE_MT7922_*.bin"
          "mediatek/WIFI_MT7922_patch_mcu_*.bin"
          "mediatek/BT_RAM_CODE_MT7922_*.bin"
          "mediatek/mt7662*.bin"

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

          "rtl_nic/rtl8153a-*.fw"

          # https://gitlab.com/kernel-firmware/linux-firmware/-/commit/2b6dd0c8
          "cirrus/cs35l41-dsp1-spk-prot-17aa38b4-spkid*-*0.bin" # spkid{0,1}-{l,r}0
          "cirrus/cs35l41/v6.61.1/halo_cspl_RAM_revB2_29.63.1.wmfw"
        ];

        extraSetup = ''
          mv -v nvidia/ad102/ nvidia/ad107/

          mv -v cirrus/cs35l41/v*/*.wmfw cirrus/cs35l41-dsp1-spk-prot-17aa38b4.wmfw
          rmdir -v cirrus/cs35l41/v* || true
          ${lib.getExe' pkgs.util-linux "rename"} -v 17aa38b4 17aa38b7 cirrus/*
        '';

        hash = "sha256-AF3g3YYsQBeWk6m0EGIl8Zh6+Kd0OFGESs9oQ+14fXo=";
        tag = pkgs.microcode-amd.version;
      })
    ];
  };

  services = {
    # FIXME: HEY this command breaks sleep, find reason, maybe its the same one
    # echo powersupersave > /sys/module/pcie_aspm/parameters/policy
    # appears to change `lspci -vv | grep 'ASPM.*abled;'`

    fprintd = {
      enable = false;
      package = pkgs.fprintd.override { libfprint = mypkgs.libfprint-fpc; };
    };
    # udev.packages = [ mypkgs.libfprint-fpc ];
  };
}
/*
      package = (pkgs.fprintd.override { libfprint = mypkgs.libfprint-fpc; }).overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
      };
*/
