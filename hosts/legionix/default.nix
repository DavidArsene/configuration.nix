{ config, mylib, ... }:
let
  hotspot-if = "wlp2s0";
in
{
  imports = with mylib.myModules; [
    amd
    desktop
    development
    laptop
    # ios
    gaming
    samba
    # spicetify
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
  #  services.create_ap TODO

  services.hostapd.enable = false;
  services.hostapd.radios = {
    ${hotspot-if} = {
      countryCode = "RO";
      band = "5g";
      channel = 0; # Automatic
      settings = { };

      wifi4.enable = false;
      wifi5.enable = false;
      wifi6 = {
        enable = true;
        operatingChannelWidth = "80+80"; # 160?
      };

      networks.${hotspot-if} = {
        ssid = "…";
        settings = { };

        authentication = {
          mode = "wpa3-sae";
          enableRecommendedPairwiseCiphers = true;
          # saeAddToMacAllow = true;

          saePasswords = [ { password = "1½⅓¼⅕⅙⅐⅛⅑⅒"; } ];
        };
      };
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
  system.stateVersion = "26.05";
  # https://nixos.org/manual/nixpkgs/unstable/release-notes#sec-nixpkgs-release-26.11-lib-breaking
}
