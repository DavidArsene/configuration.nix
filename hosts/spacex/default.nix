{
  config,
  pkgs,
  lib,
  ...
}:

let
  kernel = pkgs.linuxPackages_latest;
in
{
  imports = [ ./hardware.nix ];

  boot = {
    kernelModules = [ "ntsync" ];

    blacklistedKernelModules = [
      "sp5100_tco" # watchdog
      "ntfs3" # use NTFSPLUS
    ];

    kernelPackages = kernel;

    extraModulePackages = with kernel; [
      cpupower
    ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # TODO: Steam still requires 32bit
  nixos.minify.no32BitGraphics = lib.mkForce false;

  powerManagement.enable = true;

  environment.systemPackages = with pkgs; [
    discord
    jetbrains.idea
    (callPackage (helium-flake + /helium.nix) {
      libICE = libice;
      libSM = libsm;
      libX11 = libx11;
      libXScrnSaver = libxscrnsaver;
      libXcomposite = libxcomposite;
      libXcursor = libxcursor;
      libXdamage = libxdamage;
      libXext = libxext;
      libXfixes = libxfixes;
      libXft = libxft;
      libXi = libxi;
      libXrandr = libxrandr;
      libXrender = libxrender;
      libXt = libxt;
      libXtst = libxtst;
    })

  ];

  services = {
    flatpak.enable = true;
    blueman.enable = true;

    xserver.videoDrivers = [ "nvidia" ];

    power-profiles-daemon.enable = true;

    fstrim.enable = true;

    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };
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
