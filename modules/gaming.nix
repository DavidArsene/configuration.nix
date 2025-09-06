{
  edge,
  nix-gaming,
  pkgs,
  ...
}:
{
  imports = with nix-gaming.nixosModules; [
    platformOptimizations
    wine
  ];

  # nix-gaming wine
  programs.wine = {
    enable = false;
    package = nix-gaming.packages.x86_64-linux.wine-ge;
    binfmt = true;
    ntsync = true;
  };

  # home-manager
  # programs.mangohud.enable = true;

  environment.systemPackages =
    (with edge; [
      # wineCustom
      winetricks

      # dxvk
      vkd3d-proton
      # steam-run-free

      goverlay
      (mangohud.override {
        # No gamescope, mangoapp, and mangohudctl.
        # Removes OpenGL and Xorg dependencies.
        gamescopeSupport = false;
        lowerBitnessSupport = false;
      })

      # (q4wine.override {
      #   wine = wineCustom;
      # })

      # TODO: no cuda?
      # nvtopPackages.nvidia
      amdgpu_top
      vulkan-tools
      vulkan-tools-lunarg
    ])

    ++ (with pkgs; [
      (callPackage ../pkgs/prismlauncher-zing.nix { })
      olympus # Mod Loader for Celeste
      # Uses same dotnet

      dotnet-runtime # for Terraria / tModLoader
      innoextract # for Windows GOG installers
      # for Linux installers use https://github.com/Yepoleb/gogextract
    ]);

  environment.sessionVariables = { };

  services = {
    lact.enable = false; # TODO:
  };

  programs = {
    steam = {
      enable = false;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
          RADV_TEX_ANISO = 16;
        };
        # extraLibraries =
        #   p: with p; [
        #     atk
        #   ];
      };

      # nix-gaming platformOptimizations
      platformOptimizations.enable = true;
    };

    gamemode = {
      enable = true;
      enableRenice = true;

      settings = { };
      # manually set for now
    };

    gamescope = {
      enable = false;
      args = [
        "--rt"
        "--prefer-vk-device 8086:9bc4"
      ];
      capSysNice = 12;
      env = # for Prime render offload on Nvidia laptops.
        # Also requires `hardware.nvidia.prime.offload.enable`.
        {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
    };
  };
}
