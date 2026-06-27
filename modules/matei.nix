{ pkgs, ... }:
{
  services = {
    xserver.desktopManager.mate = {
      enable = true;
      enableWaylandSession = true;
      extraPanelApplets = with pkgs; [ mate-applets ];
      extraCajaExtensions = with pkgs; [ caja-extensions ];
    };

    udisks2.mountOnMedia = true;
  };
}
