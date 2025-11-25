{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  virtualisation.virtualbox.guest.enable = false;
  # virtualisation.waydroid.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    # graceful = true;
    configurationLimit = 7;
    edk2-uefi-shell.enable = true;
    # netbootxyz.enable = true;
    windows."11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
      sortKey = "hahaha";
    };
  };

  programs.virt-manager.enable = false;
  # programs.virt-manager.package = pkgs.virt-manager;
  virtualisation.libvirtd = {
    enable = false;
    qemu = {
      package = pkgs.qemu_kvm;
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
