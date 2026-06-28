{ self, pkgs, ... }:

let

  kernel = pkgs.linuxPackages_latest;
  davidcfg = self.nixosConfigurations."legionix".config;
in
{
  inherit (davidcfg.boot) initrd kernelModules blacklistedKernelModules;
  inherit (davidcfg.hardware) nvidia usbStorage bluetooth;
  inherit (davidcfg.services)
    xserver
    power-profiles-daemon
    fstrim
    fwupd
    ;

  boot = {
    kernelPackages = kernel;

    extraModulePackages = with kernel; [
      cpupower
    ];

    loader.efi.canTouchEfiVariables = true;
  };

  fileSystems = TODO;

  hardware = {
    cpu.intel.updateMicrocode = true;
    cpu.intel.npu.enable = true;
    # cpu.intel.sgx
    firmware = [ pkgs.linux-firmware ];

  };

  powerManagement.enable = true;

}
