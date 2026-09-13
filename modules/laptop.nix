{ config, pkgs, ... }: {

  boot = {
    loader.efi.canTouchEfiVariables = true;

    # use NTFSPLUS
    blacklistedKernelModules = [ "ntfs3" ];
  };

  hardware = {
    usbStorage.manageShutdown = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        # https://github.com/bluez/bluez/blob/master/src/main.conf
        General = {
          Experimental = true;
          Testing = true;
          KernelExperimental = true;
        };
      };
    };

  };
  powerManagement = {
    enable = true;
    # bootCommands = "${pkgs.networkmanager}/bin/nmcli radio wifi on";
    # scsiLinkPolicy = "med_power_with_dipm"; # TODO: what?
  };

  #* Mostly from nixos-hardware
  services = {
    #? Desktop environments use the D-Bus interface provided by PPD.
    #? The alternatives are TLP and tuned, which expose a compatible
    #? interface via ".tlp.pd" and ".tuned.ppdSupport" respectively.
    power-profiles-daemon.enable = false;
    # auto-cpufreq.enable = false;

    tuned = {
      enable = true;
      # https://github.com/redhat-performance/tuned/blob/master/tuned-main.conf
      settings = {
        # daemon = true;
        # dynamic_tuning = false;
        sleep_interval = 10;
        update_interval = 20;
        recommend_command = false;
      };

      ppdSupport = true;
      # https://github.com/redhat-performance/tuned/blob/master/tuned/ppd/ppd.conf
      #      ppdSettings = {
      #        main = {
      #          default = "balanced";
      #          battery_detection = true;
      #          # sysfs_acpi_monitor = true;
      #        };
      #        profiles = {
      #          power-saver = "powersave";
      #          balanced = "balanced";
      #          performance = "balanced";
      #        };
      #        battery = {
      #          power-saver = "powersave";
      #          balanced = "balanced";
      #        };
      #      };
    };

    logind.settings.Login = {
      IdleAction = "sleep";
      IdleActionSec = 10 * 60;
      # Handle* options overriden(?) by DE
    };

    # NOTE: filesystems mounted with `discard=async`
    # TODO: check they actually are, esp. /home ext4
    # fstrim.enable = true;

    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };

    ananicy = {
      enable = true;
      package = pkgs.ananicy-rules-cachyos;
      rulesProvider = config.services.ananicy.package;
    };
  };
}
