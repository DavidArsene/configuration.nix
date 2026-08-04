{
  config,
  pkgs,
  lib,
  mylib,
  helium,
  ...
}:

let
  kernel = pkgs.linuxPackages_latest;
in
{
  imports = with mylib.myModules; [
    gaming
    laptop
    matei

    ./hardware.nix
  ];

  boot = {
    kernelPackages = kernel;

    extraModulePackages = with kernel; [ cpupower ];
  };

  environment.systemPackages = with pkgs; [
    discord
    jetbrains.idea
    helium.packages.helium

  ];

  services = {
    flatpak.enable = true;
    blueman.enable = true;
  };

  # undo's
  users.myself = "matei";
  users.users.${config.users.myself} = {
    description = lib.mkForce "Matei";
    hashedPassword = lib.mkForce "$y$j9T$9QNaevgCvYJomcvnXrwR7.$dhNjxeS7dO.vGdg0vcWl4Z32TyBDBW2TrObjt/WidI6";
  };
  programs.git.config = {
    user.name = lib.mkForce "not-patches";
    user.email = lib.mkForce "mateiosul14@gmail.com";
  };

  networking.networkmanager.enable = lib.mkForce true;
  nix.package = lib.mkForce pkgs.nixVersions.latest;

  system.stateVersion = "26.05";
}
