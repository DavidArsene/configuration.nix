{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./looking-glass.nix
  ];

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

  services.duplicati = {
    # enable = true; FIXME: good but large
    user = config.users.myself;
    parameters = "";
  };

  virtualisation.incus = {
    enable = false;
    package = pkgs.incus; # default is lts
    socketActivation = true;
    #! agent.enable = true; # on guests
    ui.enable = true;
  };

  # HARRY DID YOU READ THE COMMENT?
  system.stateVersion = "26.05";
  # https://nixos.org/manual/nixpkgs/unstable/release-notes#sec-nixpkgs-release-26.11-lib-breaking
}
