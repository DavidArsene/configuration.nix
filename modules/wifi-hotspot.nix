{ config, lib, ... }: {

  options.david.hotspot = {
    phy = lib.mkOption {
      type = lib.types.str;
      default = "wlp2s0";
    };
  };

  imports = [ ./networking.nix ];

  config =
    let
      cfg = config.david.hotspot;
      apIf = cfg.phy + "ap0";
      staIf = cfg.phy + "sta0";
    in
    {

      networking = {
        wlanInterfaces = {
          # "Station" interface, to connect to Wi-Fi using NM
          ${staIf}.device = cfg.phy;

          # "Access Point" used by hostapd
          ${apIf}.device = cfg.phy;
          # fourAddr = true;

          # TODO: p2p-{client,go,device}
        };

        networkmanager.unmanaged = [ apIf ];
      };

      services.hostapd = {
        enable = true;
        radios.${apIf} = {
          countryCode = "RO";
          band = "5g";
          channel = 0; # Automatic
          settings = { };

          wifi4.enable = false;
          wifi5.enable = false;
          wifi6.enable = true;
          # wifi6.operatingChannelWidth = "80+80"; # 160?

          networks.${apIf} = {
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

      # Local-only subnet for peers
      # TODO: netdevs?
      systemd.network = {
        enable = true;
        networks.${apIf} = {
          matchConfig.Name = apIf;
          networkConfig = {
            Address = [ "192.168.77.1/24" ];
            DHCPServer = false; # FIXME: true?
            IPForward = false; # no internet routing
            IPv6AcceptRA = false;
            LinkLocalAddressing = true;
          };
          dhcpServerConfig = {
            PoolOffset = 10;
            PoolSize = 200;
            EmitRouter = true;
            Router = "192.168.77.1";
            EmitDNS = false;
          };
        };
      };

      /*
        warnings = lib.optional (
          config.networking.wireless.iwd.settings.DriverQuirks.DefaultInterface != "?*"
        ) "services/networking/iwd.nix didn't set iwd DefaultInterface!";
      */
    };
}
