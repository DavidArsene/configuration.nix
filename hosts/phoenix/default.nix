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

  nix.enable = false;
  # nix.package = lib.mkForce pkgs.nixVersions.latest;

  environment.systemPackages = with pkgs; [
    fex-headless
    #? All the options for using FEX RootFS images
    erofs-utils
    squashfsTools
    squashfuse
  ];

  services = {
    # handled by below services
    resolved.enable = lib.mkForce false;

    #    pihole-ftl = {
    #      enable = true;
    #      settings.misc.readOnly = false;
    #    };
    #    pihole-web.enable = true;
    #    pihole-web.ports = [ 169 ];

    technitium-dns-server.enable = true;
    #    unbound.enable = true;

    factorio = {
      enable = false; # setup fex first
      nonBlockingSaving = true;
      lan = true;
    };

    cloudflared = {
      enable = true;

      # API access to entire "zone" (domain)
      # https://dash.cloudflare.com/profile/api-tokens
      # created using `cloudflared login`
      # https://developers.cloudflare.com/tunnel/advanced/local-management/tunnel-permissions
      # path embedded as-is into systemd service, no --impure needed
      # certificateFile = "/home/david/.cloudflared/cert.pem";

      # FIXME: okay now I'm really confused.
      # I got the credentialsFile by manually running `cloudflared tunnel create`,
      # so what purpose does certificateFile have?
      tunnels = {
        "4fd86244-4fdc-4a73-b9f1-c9b3207be730" = {
          credentialsFile = "/home/david/.cloudflared/phoenix.json";
          default = "http_status:404";
          edgeIPVersion = "6";
        };
      };

      #? A secret third thing: convert a token to credentialsFile json
      #$ echo TOKEN | base64 -d | jq -r '{ AccountTag: .a, TunnelId: .t, TunnelSecret: .s }' | tee *.json
    };

    stirling-pdf = {
      enable = false;
      package =
        let
          homepage = "https://github.com/Stirling-Tools/Stirling-PDF";
          version = "2.8.0";
        in
        pkgs.fetchurl {
          url = "${homepage}/releases/download/v${version}/Stirling-PDF-with-login.jar";
          hash = "sha256-175xODiXS9MGdlF2BNBi8q09uYOkQV9nIsCdQQMV390=";
        };
    };

    linkwarden = {
      enable = false;
      port = 121123; # lkw
      # enableRegistration = true;
    };
    meilisearch = {
      enable = false;
      settings = {
        experimental_reduce_indexing_memory_usage = true;
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
