{ lib, pkgs, ... }:
{
  nix = {
    settings = {
      auto-allocate-uids = true;
      # ca-derivations = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "nix-command"
        "flakes"
        "local-overlay-store"
        "pipe-operators"
      ];
      use-xdg-base-directories = true;
      # lazy-trees = true;
    };

    channel.enable = false;

    package = lib.mkDefault pkgs.nixVersions.latest;
  };
}
