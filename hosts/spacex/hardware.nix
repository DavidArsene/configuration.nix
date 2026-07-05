{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "vmd" "sdhci_pci" "nvme" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NixOS";
      fsType = "btrfs";
      options=["noatime" "compress=zstd:3"];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "umask=0022" ];
    };
}
