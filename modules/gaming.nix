{
  edge ? pkgs,
  #  nix-gaming,
  pkgs,
  mylib,
  mypkgs,
  ...
}:
let
  wineCustom = pkgs.wine.override {

    wineRelease = "staging";
    wineBuild = "wine64";
    gettextSupport = false; # true; # i18n
    fontconfigSupport = true;
    alsaSupport = false;
    gtkSupport = false;
    openglSupport = true;
    tlsSupport = true;
    gstreamerSupport = false;
    cupsSupport = false;
    dbusSupport = true;
    openclSupport = false;
    cairoSupport = true; # Graphics library
    odbcSupport = false;
    netapiSupport = false; # samba ??
    cursesSupport = false;
    vaSupport = true; # VA-API video acceleration
    pcapSupport = false; # network packet capture
    v4lSupport = false; # camera video input
    saneSupport = false; # scanner access
    gphoto2Support = false; # camera access
    krb5Support = false; # true; ## "no Kerberos support, expect problems"
    pulseaudioSupport = false; # true; # Expects at least one driver from "pulse,alsa,oss,coreaudio"
    udevSupport = true; # /shrug why not
    xineramaSupport = false; # X11 stuff
    vulkanSupport = true;
    sdlSupport = true; # SDL2 graphics library
    usbSupport = true; # libusb /shrug
    mingwSupport = false;
    waylandSupport = true;
    x11Support = false;
    embedInstallers = false; # Mono and Gecko MSI installers
  };
in
{
  #  imports = with nix-gaming.nixosModules; [
  #    platformOptimizations
  #    wine
  #
  #    ../pkgs/steam/program.nix
  #  ];

  # nix-gaming wine
  #  programs.wine = {
  #    enable = false;
  #    package = nix-gaming.packages.x86_64-linux.wine-ge;
  #    binfmt = true;
  #    ntsync = true;
  #  };

  # home-manager
  # programs.mangohud.enable = true;

  environment.systemPackages =

    (with edge; [
      # wineCustom
      # winetricks

      #> Dependencies
      # dxvk
      # vkd3d-proton
      lsfg-vk
      lsfg-vk-ui

      #> Extras
      # pkgs.goverlay
      # (mangohud.override {
      #> No gamescope, mangoapp, and mangohudctl.
      #> Removes OpenGL and Xorg dependencies.
      # gamescopeSupport = false;
      # lowerBitnessSupport = false;
      # })

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
      #! mypkgs.prismlauncher-zing
      # olympus #> Mod Loader for Celeste
      #> Uses same dotnet

      (mylib.mkFreshOnly dotnet-runtime) # > for Terraria / tModLoader
      innoextract # > for Windows GOG installers
      #> for Linux installers use https://github.com/Yepoleb/gogextract
    ]);

  environment.sessionVariables = { };

  services = {
    lact.enable = false; # TODO:
  };

  # use newer one, same as steam
  # edit: never do this
  # hardware.graphics.package = edge.mesa;

  programs = {
    steam = {
      # enable = true;
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
