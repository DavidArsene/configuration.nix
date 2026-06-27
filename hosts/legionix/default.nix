{ pkgs, custom, ... }:
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
    netbootxyz.enable = false;

    windows."11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
      sortKey = "hahaha";
    };
  };

  services.duplicati = {
    # enable = true; FIXME: good but large
    user = custom.myself;
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
}
