{
  # nix-gaming,
  pkgs,
  mylib,
  mypkgs,
  newpkgs,
  ...
}:
let
  # pkgs = newpkgs; # LSP
in
{
  #  imports = with nix-gaming.nixosModules; [
  #    platformOptimizations
  #    wine
  #  ];

  # TODO: home-manager
  # programs.mangohud.enable = true;

  environment.systemPackages =
    (with newpkgs; [
      # FIXME:
      # wineCustom
      # winetricks
      umu-launcher

      #> Dependencies
      # dxvk
      # vkd3d-proton
      lsfg-vk
      (mylib.mkFreshOnly lsfg-vk-ui)

      #> Extras
      # pkgs.goverlay
      (mangohud.override {
        #? No gamescope, mangoapp, and mangohudctl.
        #? Removes OpenGL and Xorg dependencies.
        gamescopeSupport = false;
        lowerBitnessSupport = false;
      })

      # (q4wine.override {
      #   wine = wineCustom;
      # })

      # TODO: no cuda?
      # nvtopPackages.nvidia
      pkgs.amdgpu_top
      vulkan-tools
      (mylib.mkFreshOnly vulkan-tools-lunarg)
    ])

    ++ (with pkgs; [
      # (mypkgs.minecraft.prismlauncher-zing.override {
      #   glfw-wayland = mylib.optimizedBuild pkgs mypkgs.minecraft.glfw-wayland;
      # })
      # olympus #> Mod Loader for Celeste
      #> Uses same dotnet

      the-powder-toy

      (mylib.mkFreshOnly dotnet-runtime) # > for Terraria / tModLoader
      innoextract # > for Windows GOG installers
      #* for Linux installers use https://github.com/Yepoleb/gogextract
    ]);

  comment = ''
    reaper does: prctl(36, 1, 0, 0, 0) != -1

        $STEAM/ubuntu12_32/reaper SteamLaunch AppId=348550 \
        -- $STEAM/ubuntu12_32/steam-launch-wrapper \
        -- $STEAM/steamapps/common/SteamLinuxRuntime_sniper/_v2-entry-point --verb=waitforexitandrun \
        -- $STEAM/compatibilitytools.d/GE-Proton8-27/proton waitforexitandrun \
        $STEAM/steamapps/common/Game/Game.exe
  '';

  environment.sessionVariables = { };

  services = {
    lact.enable = false; # TODO:
  };

  programs = {
    steam = {
      enable = false;
      package = newpkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
        };
        extraArgs = "-dev";
      };
      extraCompatPackages = with pkgs; [ steam-play-none ];

      # extraEnv = {
      #   MANGOHUD = true;
      #   OBS_VKCAPTURE = true;
      #   RADV_TEX_ANISO = 16;
      # };

      # nix-gaming platformOptimizations
      #      platformOptimizations.enable = true;
    };

    gamemode = {
      # enable = true;
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
      # capSysNice = true;
      env = # > for Prime render offload on Nvidia laptops.
        #> Also requires `hardware.nvidia.prime.offload.enable`.
        {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
    };
  };
}
