{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    libimobiledevice

    idevicerestore
    ideviceinstaller
    libirecovery
    libideviceactivation

    # ifuse
    # idescriptor
  ];

  services = {
    usbmuxd.enable = true;
    usbmuxd.package = pkgs.usbmuxd; # usbmuxd2

    # For AirPlay with UxPlay
    avahi = {
      enable = false;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };

}
