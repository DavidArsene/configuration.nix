{ lib, pkgs, ... }:
{
  imports = [ ./oci.nix ];

  nix.buildMachines = lib.mkForce [ ];

  programs.java.package = pkgs.temurin-jre-bin-25;

  environment.systemPackages = with pkgs; [
    fex-headless
    #? All the options for using FEX RootFS images
    erofs-utils
    squashfsTools
    squashfuse
  ];

  services = {
    # Enable IP forwarding required for exit nodes
    tailscale.useRoutingFeatures = "server";

    pihole-ftl = {
      enable = true;
      settings.misc.readOnly = false;
    };
    pihole-web.enable = true;
    pihole-web.ports = [ 169 ];

    technitium-dns-server.enable = true;
    unbound.enable = true;
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
