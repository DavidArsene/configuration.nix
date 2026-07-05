{ pkgs, ... }:
{
  services = {
    xserver.desktopManager.mate = {
      enable = true;
      enableWaylandSession = true;
      extraPanelApplets = with pkgs; [ mate-applets ];
      extraCajaExtensions = with pkgs; [ caja-extensions ];
    };

    xserver.displayManager.lightdm = {
		enable = true;
		greeter.enable = false;
	};
	xserver.enable = true;
displayManager.defaultSession =  "mate";
displayManager.autoLogin.enable = true;
displayManager.autoLogin.user = "matei";

ayatana-indicators = {
    enable = true;
    packages = with pkgs; [
        ayatana-indicator-datetime 
        ayatana-indicator-display
        ayatana-indicator-messages
        ayatana-indicator-power
        ayatana-indicator-session
        ayatana-indicator-sound
        #ayatana-webmail
    ];
};


    udisks2.mountOnMedia = true;
  };
}
