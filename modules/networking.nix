{ config, ... }:
let
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
      # FIXME: conditional?
      enable = true;
    };

    tailscale = {
      enable = true;
      disableUpstreamLogging = true;

      # Enable Linux IP forwarding.
      # Used on phoenix for Tailscale's exit node.
      # Used on legionix for various experiments.
      # TODO: needed for bluetooth pan?
      # TODO: conditional?
      useRoutingFeatures = "server";
    };
  };

}
