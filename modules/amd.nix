{ config, pkgs, ... }: {

  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.seamless=1"
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenergy
    # zenpower
  ];

  environment.systemPackages = with pkgs; [
    ryzenadj
    ryzen-monitor-ng
    amdctl
  ];

  hardware = {
    cpu.amd.ryzen-smu.enable = true;
    cpu.amd.updateMicrocode = true;

    amdgpu = {
      overdrive.enable = true;
      overdrive.ppfeaturemask = "0xffffffff";

      # initrd.enable = true; # bloats initrd by 15MB
    };
  };

}
