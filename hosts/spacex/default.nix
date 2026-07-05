{ self, pkgs, helium-flake, ... }:

let

  kernel = pkgs.linuxPackages_latest;
  davidcfg = self.nixosConfigurations."legionix".config;
in
{
  imports = [ ./hardware.nix ];

  boot = { inherit (davidcfg.boot) kernelModules blacklistedKernelModules; };
  hardware = { inherit (davidcfg.hardware) usbStorage bluetooth; };
  services = { inherit (davidcfg.services)
    power-profiles-daemon
    fstrim
    fwupd
  ; };

  nixos.minify.no32BitGraphics = pkgs.lib.mkForce false;
  
  boot = {
    kernelPackages = kernel;

    extraModulePackages = with kernel; [
      cpupower
    ];
    loader.efi.canTouchEfiVariables=  true;
    loader.systemd-boot.enable = true;
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    cpu.intel.npu.enable = true;
    # cpu.intel.sgx
    firmware = [ pkgs.linux-firmware ];

  };

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

system.stateVersion = "26.11";

    # Matei added this
    services = {
        flatpak.enable = true;
        blueman.enable = true;
        xserver.videoDrivers = [ "nvidia" ];
    };

    networking = {
        wireless.userControlled = true;

    };

    users.extraUsers.matei.extraGroups = [ "wheel" "networkmanager" ];
    hardware.nvidia.open = true;
}
