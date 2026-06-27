{
  config,
  # nix-gaming,
  pkgs,
  ...
}:
let
  # pkgs = newpkgs; # LSP
  steam-ran = if config.programs.steam.enable then pkgs.steam-run else pkgs.steam-run-free;
in
{
  # TODO: home-manager
  # programs.mangohud.enable = true;

  environment.systemPackages =
    (with pkgs; [
      # (mylib.marchNative pkgs mypkgs.wine)
      # winetricks
      steam-ran
      # wine-wayland

      # TODO: wine for android
      # android-translation-layer
      # FIXME: coolercontrol daemon
      coolercontrol.coolercontrol-gui

      #> Dependencies
      # dxvk
      # vkd3d-proton
      lsfg-vk
      lsfg-vk-ui

      #> Extras
      # pkgs.goverlay
      # (mangohud.override {
      #   #? No gamescope, mangoapp, and mangohudctl.
      #   #? Removes OpenGL and Xorg dependencies.
      #   gamescopeSupport = false;
      #   lowerBitnessSupport = false;
      # })
      mangohud
      mangojuice

      # (q4wine.override { wine = wineCustom; })

      # TODO: no cuda?
      # nvtopPackages.nvidia
      pkgs.amdgpu_top
      vulkan-tools
      vulkan-tools-lunarg
    ])

    ++ (with pkgs; [
      # (mypkgs.minecraft.prismlauncher-zing.override {
      #   glfw-wayland = mylib.marchNative pkgs mypkgs.minecraft.glfw-wayland;
      # })

      innoextract # > for Windows GOG installers
      #* for Linux installers use https://github.com/Yepoleb/gogextract
    ]);

  comment = ''
    reaper does: prctl(36, 1, 0, 0, 0) != -1

    $STEAM/ubuntu12_32/reaper SteamLaunch AppId=###### \
    -- $STEAM/ubuntu12_32/steam-launch-wrapper \
    -- $STEAM/steamapps/common/SteamLinuxRuntime_sniper/_v2-entry-point --verb=waitforexitandrun \
    -- $STEAM/compatibilitytools.d/*/proton waitforexitandrun \
    $STEAM/steamapps/common/Game/Game.exe
  '';

  services = {
    lact.enable = false; # TODO:
  };

  programs = {
    steam = {
      enable = true;
      package = pkgs.steam.override {

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
  };
}
