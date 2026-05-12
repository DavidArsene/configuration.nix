{ pkgs, custom, ... }:
{
  imports = [ ./hardware.nix ];

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

  programs.virt-manager.enable = false;
  # programs.virt-manager.package = pkgs.virt-manager;
  virtualisation.libvirtd = {
    enable = false;
    qemu = {
      package = pkgs.qemu_kvm;
    };
  };
  # tap.vhost = true;

  virtualisation.incus = {
    enable = false;
    package = pkgs.incus; # default is lts
    socketActivation = true;
    #! agent.enable = true;
    ui.enable = true;
  };

  # services.usbmuxd.enable = true;

  # HARRY DID YOU READ THE COMMENT?
  system.stateVersion = "26.05";
}
