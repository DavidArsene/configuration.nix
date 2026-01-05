{ pkgs, ... }:
let
  first = "05";
  second = "11";

  # Did you read the comment?
  year = 2026;
  half = first;
in
{
  imports = [ ./hardware.nix ];

  virtualisation.virtualbox.guest.enable = false;
  # virtualisation.waydroid.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    configurationLimit = 6;
    editor = false; # TODO: better default worthy?

    edk2-uefi-shell.enable = true;
    netbootxyz.enable = true;

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

  system.stateVersion = "${toString (year - 2000)}.${half}";
}
