{ lib, ... }:
{
  imports = [ ./oci.nix ];

  nix.buildMachines = lib.mkForce [ ];
  console.enable = true;

  programs.java.enable = lib.mkForce false;

  services = {
    pihole-web.enable = true;
    technitium-dns-server.enable = true;
    unbound.enable = true;
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
