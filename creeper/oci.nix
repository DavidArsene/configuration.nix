{ lib, ... }:
{
  # imports = [(modulesPath + /profiles/qemu-guest.nix)];

  # Inline qemu-guest.nix to avoid modulesPath
  boot.initrd = {
    availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"

      "xhci_pci" # oci-specific
    ];
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_gpu"
    ];
    includeDefaultModules = false;
  };

  # https://github.com/nix-community/infra/pull/1068
  # Make it easier to recover via serial console in case something goes wrong.
  services.getty.autologinUser = "root";

  networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/oci-common.nix

  # Taken from /proc/cmdline of Ubuntu 20.04.2 LTS on OCI
  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    "console=ttyAMA0,115200"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/configuringntpservice.htm#Configuring_the_Oracle_Cloud_Infrastructure_NTP_Service_for_an_Instance
  networking.timeServers = [ "169.254.169.254" ];

  # Otherwise the instance may not have a working network-online.target
  networking.useNetworkd = lib.mkDefault true;

  nixpkgs.hostPlatform = "aarch64-linux";
}
