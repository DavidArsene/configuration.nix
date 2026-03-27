{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./oci.nix ];

  nix.buildMachines = lib.mkForce [ ];

  programs.java.package = pkgs.temurin-jre-bin-25;

  environment.systemPackages = with pkgs; [
    fex-headless
    #? All the options for using FEX RootFS images
    erofs-utils
    squashfsTools
    squashfuse
  ];

  services = {
    # Enable IP forwarding required for exit nodes
    tailscale.useRoutingFeatures = "server";

    pihole-ftl = {
      enable = true;
      settings.misc.readOnly = false;
    };
    pihole-web.enable = true;
    pihole-web.ports = [ 169 ];

    technitium-dns-server.enable = true;
    unbound.enable = true;

    factorio = {
      enable = false; # setup fex first
      nonBlockingSaving = true;
      lan = true;
    };

    cloudflared = {
      enable = true;
      tunnels = {
        "${config.networking.hostName}" = {
          ingress = {
            "pdf.davidarsene.ro" = "http://localhost:8080";
          };
          default = "http_status:404";
          edgeIPVersion = "6";
        };
      };
    };

    stirling-pdf = {
      enable = true;
      package =
        let
          variants = {
            backendOnly = "-server";
            openSource = "";
            commercial = "-with-login";
          };
          homepage = "https://github.com/Stirling-Tools/Stirling-PDF";
          version = "2.7.3";
        in
        pkgs.fetchurl {
          url = "${homepage}/releases/download/v${version}/Stirling-PDF${variants.commercial}.jar";
          hash = "sha256-bw6tPeZBWzD62Aa+0GfNAghDDRzf92ovs3gpZNgobs0=";
        };
    };
  };

  systemd.services.stirling-pdf = {
    path = with pkgs; [
      # calibre FIXME: big; also provides ebook-convert
      # rar FIXME: not in aarch64
      ffmpeg-headless
      imagemagick
      fontforge # -fonttools ??
    ];

    serviceConfig = {
      ExecStart = lib.mkForce "${lib.getExe config.programs.java.package} -jar ${config.services.stirling-pdf.package}";
    };
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
