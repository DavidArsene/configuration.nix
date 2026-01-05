{ config, newpkgs, ... }:
let
  pkgs = newpkgs;

  #? Defaults to checking display managers.
  isDesktop = config.services.displayManager.enable;

  #? Disabled by minimal.nix
  hasFirewall = config.networking.firewall.enable;

in
{
  #? Use NetworkManager on desktop for easy Wi-Fi
  networking.networkmanager = {
    enable = isDesktop;
    dns = "systemd-resolved";
    plugins = [ ];

    wifi.backend = "iwd";
    wifi.powersave = true;
    # todo sh -c 'echo 2 > /proc/sys/net/ipv6/conf/wlan0/use_tempaddr' failed with exit code 1.
  };

  networking = {
    useNetworkd = !isDesktop;
    search = [ "lab" ];
    # nftables.enable = ??? FIXME:

  };

  services = {
    resolved = {
      enable = true;
    };

    tailscale = {
      enable = true;
      disableUpstreamLogging = true;
      # package = pkgs.tailscale;
    };
  };

  comment.services.netbird = {
    #* No `enable` needed.
    clients.homelab = {

      port = 51820;
      name = "netbird";
      interface = "wt0";
      hardened = false;

      autoStart = false;
      openFirewall = hasFirewall;
      openInternalFirewall = hasFirewall;

    };
    ui.enable = false;
    package = pkgs.netbird;
    # useRoutingFeatures = "";
  };
}
