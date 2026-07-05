{ config, pkgs, ... }:
{
  services = {

    xserver = {
      enable = true;
      desktopManager.mate = {
        enable = true;
        enableWaylandSession = true;
        extraPanelApplets = with pkgs; [ mate-applets ];
        extraCajaExtensions = with pkgs; [ caja-extensions ];
      };

      displayManager = {
        lightdm = {
          enable = true;
          greeter.enable = false;
        };
      };
    };

    displayManager.defaultSession = "mate";
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = config.users.myself;

    udisks2.mountOnMedia = true;

    ayatana-indicators = {
      enable = true;
      packages = with pkgs; [
        ayatana-indicator-datetime
        ayatana-indicator-display
        ayatana-indicator-messages
        ayatana-indicator-power
        ayatana-indicator-session
        ayatana-indicator-sound
        # ayatana-webmail
      ];
    };

  };
}
