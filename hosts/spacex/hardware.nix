{
  pkgs,
  ...
}:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "vmd"
    "sdhci_pci"
    "nvme"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd:3"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "umask=0022" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    cpu.intel.npu.enable = true;
    # cpu.intel.sgx
    firmware = [ pkgs.linux-firmware ];

    nvidia.prime.intelBusId = "PCI:0@0:2:0"; # lspci = (@0) 64:00.0
  };
}
