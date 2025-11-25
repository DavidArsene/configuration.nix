{ lib, ... }:
{
  imports = [ ./oci.nix ];

  nix.buildMachines = lib.mkForce [ ];

  programs.java.enable = lib.mkForce false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
