{
  config,
  mypkgs,
  lib,
  pkgs,
  ...
}:

{
  # TODO: home-manager
  # programs.mangohud.enable = true;

  environment.systemPackages = with pkgs; [
    # (mylib.marchNative pkgs mypkgs.wine)
    # winetricks

    # TODO: wine for android
    # android-translation-layer

    lsfg-vk
    lsfg-vk-ui

    mangohud
    mangojuice
    goverlay

    # nvtopPackages.nvidia
    amdgpu_top

    vulkan-tools
    vulkan-tools-lunarg

    # (mypkgs.minecraft.prismlauncher-zing.override {
    #   glfw-wayland = mylib.marchNative pkgs mypkgs.minecraft.glfw-wayland;
    # })

    innoextract # > for Windows GOG installers
    #* for Linux installers use https://github.com/Yepoleb/gogextract
  ];

  boot.kernelModules = [ "ntsync" ];

  hardware.nvidia = {
    dynamicBoost.enable = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    # ! using nvidia-smi wakes gpu and doesn't reflect real state

    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.bleeding_edge;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
        offloadCmdMainProgram = "prime-run";
      };
      # > if lspci shows "0001:02:03.4", set this option to "PCI:2@1:3:4".
      # > lspci might omit the PCI domain (0001 above) if it is zero. Use "@0" instead.
      # > This option takes decimal while lspci reports hexadecimal.
      # > So, for device at domain "10000", use "@65536".
      #
      # amdgpuBusId = "...";
      # intelBusId = "...";
      nvidiaBusId = lib.mkDefault "PCI:1@0:0:0"; # lspci = (@0) 01:00.0
    };
  };

  services = {
    #* Weird way to enable NVIDIA drivers but ok
    xserver.videoDrivers = [ "nvidia" ];

    lact.enable = false; # TODO:
  };

  programs = {
    steam = {
      enable = true;
      package = mypkgs.custeam.override {

        extraEnv = {
          STEAM_RUNTIME = 0;
          MANGOHUD = true;
          # OBS_VKCAPTURE = true;
          # RADV_TEX_ANISO = 16;
        };

        extraArgs = [
          "-dev"
          "-compat-force-slr off"
          # "-pipewire-dmabuf"
        ];
      };

      extraCompatPackages = [
        pkgs.steam-play-none
        mypkgs.steam-play-nix
      ];
    };

    gamemode = {
      # enable = true;
      enableRenice = true;

      settings = { };
    };

    coolercontrol.enable = true;
    # coolercontrol.nvidiaSupport = true;
  };
}
