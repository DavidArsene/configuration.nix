{
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
    branch = "bleeding_edge";
    nvidiaSettings = false; # LACT has all settings

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

    lact.enable = true;
    # lact.settings = { }; TODO:

    cardwired.enable = true;
    cardwired.settings = {
      experimental_nvidia_block = true;
      external_display_auto_switch = true;
      # integrated = block all, smart = uses allowlist
      battery_auto_switch = true;
      battery_auto_switch_mode = "integrated";
    };
  };

  programs = {
    steam = {
      enable = true;
      package = mypkgs.custeam.override {

        extraEnv = {
          # STEAM_RUNTIME = false; NO!
          STEAM_LINUX_RUNTIME_VERBOSE = true;
          MANGOHUD = true;
          # OBS_VKCAPTURE = true;
          # RADV_TEX_ANISO = 16;

          PROTON_ENABLE_WAYLAND = true; # Proton forks only
          PROTON_NO_XIM = true; # Keyboard/Mouse -> Controller
          PROTON_USE_WOW64 = true; # Required for 64-bit only setup
          PROTON_USE_XALIA = false; # Controller -> Keyboard/Mouse
          # TODO: ntsync?
        };

        extraArgs = [
          "-dev"
          "-noverifyfiles"
          "-compat-force-slr off"
          # "-pipewire-dmabuf"
        ];
      };

      extraCompatPackages = [
        pkgs.steam-play-none
        # mypkgs.steam-play-nix
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
