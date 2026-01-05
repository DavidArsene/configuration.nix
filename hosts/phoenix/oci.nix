{ lib, modulesPath, ... }:
{
  imports = [ "${modulesPath}/virtualisation/oci-common.nix" ];

  oci.efi = true;

  # https://github.com/nix-community/infra/pull/1068
  # Make it easier to recover via serial console in case something goes wrong.
  services.getty.autologinUser = "root";

  networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  # Change some defaults from oci-common.nix
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = lib.mkForce false;

  services.openssh.enable = lib.mkForce false;
}
