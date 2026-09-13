{ config, mylib, ... }: {
  imports = with mylib.myModules; [
    amd
    desktop
    development
    laptop
    ios
    gaming
    samba
    smartcard
    # spicetify
    swap
    # wifi-hotspot
    # mypkgs.nixosModules.fprintd-fpc
    # mypkgs.nixosModules.ro-cei-pcsc
    minimal.nixosModules.kde

    ./hardware.nix
    ./looking-glass.nix
  ];

  boot.loader.systemd-boot = {
    windows."11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
      sortKey = "hahaha";
    };
  };

  #  nixos.minify.depsToReplace = {
  #    glibc = mylib.marchNative pkgs pkgs.glibc;
  #    zlib = mylib.marchNative pkgs pkgs.zlib;
  #  };

  services.duplicati = {
    # enable = true; FIXME: good but large
    user = config.users.myself;
    parameters = "";
  };

  # HARRY DID YOU READ THE COMMENT?
  system.stateVersion = "26.11";
  # https://nixos.org/manual/nixpkgs/unstable/release-notes#sec-nixpkgs-release-26.11-lib-breaking
}
